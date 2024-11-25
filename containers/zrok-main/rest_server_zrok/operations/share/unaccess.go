// Code generated by go-swagger; DO NOT EDIT.

package share

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the generate command

import (
	"net/http"

	"github.com/go-openapi/runtime/middleware"

	"github.com/openziti/zrok/rest_model_zrok"
)

// UnaccessHandlerFunc turns a function with the right signature into a unaccess handler
type UnaccessHandlerFunc func(UnaccessParams, *rest_model_zrok.Principal) middleware.Responder

// Handle executing the request and returning a response
func (fn UnaccessHandlerFunc) Handle(params UnaccessParams, principal *rest_model_zrok.Principal) middleware.Responder {
	return fn(params, principal)
}

// UnaccessHandler interface for that can handle valid unaccess params
type UnaccessHandler interface {
	Handle(UnaccessParams, *rest_model_zrok.Principal) middleware.Responder
}

// NewUnaccess creates a new http.Handler for the unaccess operation
func NewUnaccess(ctx *middleware.Context, handler UnaccessHandler) *Unaccess {
	return &Unaccess{Context: ctx, Handler: handler}
}

/*
	Unaccess swagger:route DELETE /unaccess share unaccess

Unaccess unaccess API
*/
type Unaccess struct {
	Context *middleware.Context
	Handler UnaccessHandler
}

func (o *Unaccess) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	route, rCtx, _ := o.Context.RouteInfo(r)
	if rCtx != nil {
		*r = *rCtx
	}
	var Params = NewUnaccessParams()
	uprinc, aCtx, err := o.Context.Authorize(r, route)
	if err != nil {
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}
	if aCtx != nil {
		*r = *aCtx
	}
	var principal *rest_model_zrok.Principal
	if uprinc != nil {
		principal = uprinc.(*rest_model_zrok.Principal) // this is really a rest_model_zrok.Principal, I promise
	}

	if err := o.Context.BindValidRequest(r, route, &Params); err != nil { // bind params
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}

	res := o.Handler.Handle(Params, principal) // actually handle the request
	o.Context.Respond(rw, r, route.Produces, route, res)

}
