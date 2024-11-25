// Code generated by go-swagger; DO NOT EDIT.

package account

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the generate command

import (
	"net/http"

	"github.com/go-openapi/runtime/middleware"
)

// InviteHandlerFunc turns a function with the right signature into a invite handler
type InviteHandlerFunc func(InviteParams) middleware.Responder

// Handle executing the request and returning a response
func (fn InviteHandlerFunc) Handle(params InviteParams) middleware.Responder {
	return fn(params)
}

// InviteHandler interface for that can handle valid invite params
type InviteHandler interface {
	Handle(InviteParams) middleware.Responder
}

// NewInvite creates a new http.Handler for the invite operation
func NewInvite(ctx *middleware.Context, handler InviteHandler) *Invite {
	return &Invite{Context: ctx, Handler: handler}
}

/*
	Invite swagger:route POST /invite account invite

Invite invite API
*/
type Invite struct {
	Context *middleware.Context
	Handler InviteHandler
}

func (o *Invite) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	route, rCtx, _ := o.Context.RouteInfo(r)
	if rCtx != nil {
		*r = *rCtx
	}
	var Params = NewInviteParams()
	if err := o.Context.BindValidRequest(r, route, &Params); err != nil { // bind params
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}

	res := o.Handler.Handle(Params) // actually handle the request
	o.Context.Respond(rw, r, route.Produces, route, res)

}
