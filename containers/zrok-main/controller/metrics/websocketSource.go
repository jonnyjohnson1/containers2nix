package metrics

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"github.com/gorilla/websocket"
	"github.com/michaelquigley/cf"
	"github.com/openziti/channel/v3"
	"github.com/openziti/channel/v3/websockets"
	"github.com/openziti/edge-api/rest_util"
	"github.com/openziti/identity"
	"github.com/openziti/ziti/common/pb/mgmt_pb"
	"github.com/openziti/ziti/controller/event"
	"github.com/openziti/zrok/controller/env"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"io"
	"net/http"
	"net/url"
	"time"
)

const ZitiSession = "zt-session"

func init() {
	env.GetCfOptions().AddFlexibleSetter("websocketSource", loadWebsocketSourceConfig)
}

type WebsocketSourceConfig struct {
	WebsocketEndpoint string // wss://127.0.0.1:1280/fabric/v1/ws-api
	ApiEndpoint       string // https://127.0.0.1:1280
	Username          string
	Password          string `cf:"+secret"`
}

func loadWebsocketSourceConfig(v interface{}, _ *cf.Options) (interface{}, error) {
	if submap, ok := v.(map[string]interface{}); ok {
		cfg := &WebsocketSourceConfig{}
		if err := cf.Bind(cfg, submap, cf.DefaultOptions()); err != nil {
			return nil, err
		}
		return &websocketSource{cfg: cfg}, nil
	}
	return nil, errors.New("invalid config structure for 'websocketSource'")
}

type websocketSource struct {
	cfg    *WebsocketSourceConfig
	ch     channel.Channel
	events chan ZitiEventMsg
	join   chan struct{}
}

func (s *websocketSource) Start(events chan ZitiEventMsg) (join chan struct{}, err error) {
	caCerts, err := rest_util.GetControllerWellKnownCas(s.cfg.ApiEndpoint)
	if err != nil {
		return nil, err
	}
	caPool := x509.NewCertPool()
	for _, ca := range caCerts {
		caPool.AddCert(ca)
	}

	authenticator := rest_util.NewAuthenticatorUpdb(s.cfg.Username, s.cfg.Password)
	authenticator.RootCas = caPool

	apiEndpointUrl, err := url.Parse(s.cfg.ApiEndpoint)
	if err != nil {
		return nil, err
	}
	apiSession, err := authenticator.Authenticate(apiEndpointUrl)
	if err != nil {
		return nil, err
	}

	dialer := &websocket.Dialer{
		TLSClientConfig: &tls.Config{
			RootCAs: caPool,
		},
		HandshakeTimeout: 5 * time.Second,
	}

	conn, resp, err := dialer.Dial(s.cfg.WebsocketEndpoint, http.Header{ZitiSession: []string{*apiSession.Token}})
	if err != nil {
		if resp != nil {
			if body, rerr := io.ReadAll(resp.Body); rerr == nil {
				logrus.Errorf("response body '%v': %v", string(body), err)
			}
		} else {
			logrus.Errorf("no response from websocket dial: %v", err)
		}
	}

	id := &identity.TokenId{Token: "mgmt"}
	underlayFactory := websockets.NewUnderlayFactory(id, conn, nil)

	s.join = make(chan struct{})
	s.events = events
	bindHandler := func(binding channel.Binding) error {
		binding.AddReceiveHandler(int32(mgmt_pb.ContentType_StreamEventsEventType), s)
		binding.AddCloseHandler(channel.CloseHandlerF(func(ch channel.Channel) {
			close(s.join)
		}))
		return nil
	}

	s.ch, err = channel.NewChannel("mgmt", underlayFactory, channel.BindHandlerF(bindHandler), nil)
	if err != nil {
		return nil, err
	}

	streamEventsRequest := map[string]interface{}{}
	streamEventsRequest["format"] = "json"
	streamEventsRequest["subscriptions"] = []*event.Subscription{
		{
			Type: "fabric.usage",
			Options: map[string]interface{}{
				"version": uint8(3),
			},
		},
	}

	msgBytes, err := json.Marshal(streamEventsRequest)
	if err != nil {
		return nil, err
	}

	requestMsg := channel.NewMessage(int32(mgmt_pb.ContentType_StreamEventsRequestType), msgBytes)
	responseMsg, err := requestMsg.WithTimeout(5 * time.Second).SendForReply(s.ch)
	if err != nil {
		return nil, err
	}

	if responseMsg.ContentType == channel.ContentTypeResultType {
		result := channel.UnmarshalResult(responseMsg)
		if result.Success {
			logrus.Infof("event stream started: %v", result.Message)
		} else {
			return nil, errors.Wrap(err, "error starting event streaming")
		}
	} else {
		return nil, errors.Errorf("unexpected response type %v", responseMsg.ContentType)
	}

	return s.join, nil
}

func (s *websocketSource) Stop() {
	_ = s.ch.Close()
}

func (s *websocketSource) HandleReceive(msg *channel.Message, _ channel.Channel) {
	s.events <- &ZitiEventJsonMsg{
		data: ZitiEventJson(msg.Body),
	}
}
