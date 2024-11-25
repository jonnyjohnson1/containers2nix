package main

import (
	"fmt"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/gobwas/glob"
	"github.com/openziti/zrok/endpoints"
	drive "github.com/openziti/zrok/endpoints/drive"
	"github.com/openziti/zrok/endpoints/proxy"
	"github.com/openziti/zrok/environment"
	"github.com/openziti/zrok/environment/env_core"
	"github.com/openziti/zrok/sdk/golang/sdk"
	"github.com/openziti/zrok/tui"
	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"
)

func init() {
	shareCmd.AddCommand(newSharePublicCommand().cmd)
}

type sharePublicCommand struct {
	basicAuth                 []string
	frontendSelection         []string
	backendMode               string
	headless                  bool
	insecure                  bool
	oauthProvider             string
	oauthEmailAddressPatterns []string
	oauthCheckInterval        time.Duration
	closed                    bool
	accessGrants              []string
	cmd                       *cobra.Command
}

func newSharePublicCommand() *sharePublicCommand {
	cmd := &cobra.Command{
		Use:   "public <target>",
		Short: "Share a target resource publicly",
		Args:  cobra.ExactArgs(1),
	}
	command := &sharePublicCommand{cmd: cmd}
	defaultFrontends := []string{"public"}
	if root, err := environment.LoadRoot(); err == nil {
		defaultFrontend, _ := root.DefaultFrontend()
		defaultFrontends = []string{defaultFrontend}
	}
	cmd.Flags().StringArrayVar(&command.frontendSelection, "frontend", defaultFrontends, "Selected frontends to use for the share")
	cmd.Flags().StringVarP(&command.backendMode, "backend-mode", "b", "proxy", "The backend mode {proxy, web, caddy, drive}")
	cmd.Flags().BoolVar(&command.headless, "headless", false, "Disable TUI and run headless")
	cmd.Flags().BoolVar(&command.insecure, "insecure", false, "Enable insecure TLS certificate validation for <target>")
	cmd.Flags().BoolVar(&command.closed, "closed", false, "Enable closed permission mode (see --access-grant)")
	cmd.Flags().StringArrayVar(&command.accessGrants, "access-grant", []string{}, "zrok accounts that are allowed to access this share (see --closed)")

	cmd.Flags().StringArrayVar(&command.basicAuth, "basic-auth", []string{}, "Basic authentication users (<username:password>,...)")
	cmd.Flags().StringVar(&command.oauthProvider, "oauth-provider", "", "Enable OAuth provider [google, github]")
	cmd.Flags().StringArrayVar(&command.oauthEmailAddressPatterns, "oauth-email-address-patterns", []string{}, "Allow only these email domain globs to authenticate via OAuth")
	cmd.Flags().DurationVar(&command.oauthCheckInterval, "oauth-check-interval", 3*time.Hour, "Maximum lifetime for OAuth authentication; reauthenticate after expiry")
	cmd.MarkFlagsMutuallyExclusive("basic-auth", "oauth-provider")

	cmd.Run = command.run
	return command
}

func (cmd *sharePublicCommand) run(_ *cobra.Command, args []string) {
	var target string

	switch cmd.backendMode {
	case "proxy":
		v, err := parseUrl(args[0])
		if err != nil {
			if !panicInstead {
				tui.Error("invalid target endpoint URL", err)
			}
			panic(err)
		}
		target = v

	case "web":
		target = args[0]

	case "caddy":
		target = args[0]
		cmd.headless = true

	case "drive":
		target = args[0]

	default:
		tui.Error(fmt.Sprintf("invalid backend mode '%v'; expected {proxy, web, caddy, drive}", cmd.backendMode), nil)
	}

	root, err := environment.LoadRoot()
	if err != nil {
		if !panicInstead {
			tui.Error("unable to load environment", err)
		}
		panic(err)
	}

	if !root.IsEnabled() {
		tui.Error("unable to load environment; did you 'zrok enable'?", nil)
	}

	zif, err := root.ZitiIdentityNamed(root.EnvironmentIdentityName())
	if err != nil {
		if !panicInstead {
			tui.Error("unable to access ziti identity file", err)
		}
		panic(err)
	}

	req := &sdk.ShareRequest{
		BackendMode: sdk.BackendMode(cmd.backendMode),
		ShareMode:   sdk.PublicShareMode,
		Frontends:   cmd.frontendSelection,
		BasicAuth:   cmd.basicAuth,
		Target:      target,
	}
	if cmd.closed {
		req.PermissionMode = sdk.ClosedPermissionMode
		req.AccessGrants = cmd.accessGrants
	}
	if cmd.oauthProvider != "" {
		req.OauthProvider = cmd.oauthProvider
		req.OauthEmailAddressPatterns = cmd.oauthEmailAddressPatterns
		req.OauthAuthorizationCheckInterval = cmd.oauthCheckInterval

		for _, g := range cmd.oauthEmailAddressPatterns {
			_, err := glob.Compile(g)
			if err != nil {
				if !panicInstead {
					tui.Error(fmt.Sprintf("unable to create share, invalid oauth email glob (%v)", g), err)
				}
				panic(err)
			}
		}
	}
	shr, err := sdk.CreateShare(root, req)
	if err != nil {
		if !panicInstead {
			tui.Error("unable to create share", err)
		}
		panic(err)
	}

	mdl := newShareModel(shr.Token, shr.FrontendEndpoints, sdk.PublicShareMode, sdk.BackendMode(cmd.backendMode))
	if !cmd.headless {
		proxy.SetCaddyLoggingWriter(mdl)
	}

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		cmd.shutdown(root, shr)
		os.Exit(0)
	}()

	requests := make(chan *endpoints.Request, 1024)

	switch cmd.backendMode {
	case "proxy":
		cfg := &proxy.BackendConfig{
			IdentityPath:    zif,
			EndpointAddress: target,
			ShrToken:        shr.Token,
			Insecure:        cmd.insecure,
			Requests:        requests,
		}

		be, err := proxy.NewBackend(cfg)
		if err != nil {
			if !panicInstead {
				tui.Error("error creating proxy backend", err)
			}
			panic(err)
		}

		go func() {
			if err := be.Run(); err != nil {
				logrus.Errorf("error running http proxy backend: %v", err)
			}
		}()

	case "web":
		cfg := &proxy.CaddyWebBackendConfig{
			IdentityPath: zif,
			WebRoot:      target,
			ShrToken:     shr.Token,
			Requests:     requests,
		}

		be, err := proxy.NewCaddyWebBackend(cfg)
		if err != nil {
			if !panicInstead {
				tui.Error("unable to create web backend", err)
			}
			panic(err)
		}

		go func() {
			if err := be.Run(); err != nil {
				logrus.Errorf("error running http web backend: %v", err)
			}
		}()

	case "caddy":
		cfg := &proxy.CaddyfileBackendConfig{
			CaddyfilePath: target,
			Shr:           shr,
			Requests:      requests,
		}

		be, err := proxy.NewCaddyfileBackend(cfg)
		if err != nil {
			cmd.shutdown(root, shr)
			if !panicInstead {
				tui.Error("unable to create caddy backend", err)
			}
			panic(err)
		}

		go func() {
			if err := be.Run(); err != nil {
				logrus.Errorf("error running caddy backend: %v", err)
			}
		}()

	case "drive":
		cfg := &drive.BackendConfig{
			IdentityPath: zif,
			DriveRoot:    target,
			ShrToken:     shr.Token,
			Requests:     requests,
		}

		be, err := drive.NewBackend(cfg)
		if err != nil {
			if !panicInstead {
				tui.Error("error creating drive backend", err)
			}
			panic(err)
		}

		go func() {
			if err := be.Run(); err != nil {
				logrus.Errorf("error running drive backend: %v", err)
			}
		}()

	default:
		tui.Error("invalid backend mode", nil)
	}

	if cmd.headless {
		logrus.Infof("access your zrok share at the following endpoints:\n %v", strings.Join(shr.FrontendEndpoints, "\n"))
		for {
			select {
			case req := <-requests:
				logrus.Infof("%v -> %v %v", req.RemoteAddr, req.Method, req.Path)
			}
		}

	} else {
		logrus.SetOutput(mdl)
		prg := tea.NewProgram(mdl, tea.WithAltScreen())
		mdl.prg = prg

		go func() {
			for {
				select {
				case req := <-requests:
					prg.Send(req)
				}
			}
		}()

		if _, err := prg.Run(); err != nil {
			tui.Error("An error occurred", err)
		}

		close(requests)
		cmd.shutdown(root, shr)
	}
}

func (cmd *sharePublicCommand) shutdown(root env_core.Root, shr *sdk.Share) {
	logrus.Debugf("shutting down '%v'", shr.Token)
	if err := sdk.DeleteShare(root, shr); err != nil {
		logrus.Errorf("error shutting down '%v': %v", shr.Token, err)
	}
	logrus.Debugf("shutdown complete")
}
