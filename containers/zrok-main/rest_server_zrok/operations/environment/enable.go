// Code generated by go-swagger; DO NOT EDIT.

package environment

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the generate command

import (
	"net/http"

	"github.com/go-openapi/runtime/middleware"

	"github.com/openziti/zrok/rest_model_zrok"
)

// EnableHandlerFunc turns a function with the right signature into a enable handler
type EnableHandlerFunc func(EnableParams, *rest_model_zrok.Principal) middleware.Responder

// Handle executing the request and returning a response
func (fn EnableHandlerFunc) Handle(params EnableParams, principal *rest_model_zrok.Principal) middleware.Responder {
	return fn(params, principal)
}

// EnableHandler interface for that can handle valid enable params
type EnableHandler interface {
	Handle(EnableParams, *rest_model_zrok.Principal) middleware.Responder
}

// NewEnable creates a new http.Handler for the enable operation
func NewEnable(ctx *middleware.Context, handler EnableHandler) *Enable {
	return &Enable{Context: ctx, Handler: handler}
}

/*
	Enable swagger:route POST /enable environment enable

Enable enable API
*/
type Enable struct {
	Context *middleware.Context
	Handler EnableHandler
}

func (o *Enable) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	route, rCtx, _ := o.Context.RouteInfo(r)
	if rCtx != nil {
		*r = *rCtx
	}
	var Params = NewEnableParams()
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
