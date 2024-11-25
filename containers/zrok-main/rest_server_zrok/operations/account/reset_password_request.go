// Code generated by go-swagger; DO NOT EDIT.

package account

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the generate command

import (
	"context"
	"net/http"

	"github.com/go-openapi/runtime/middleware"
	"github.com/go-openapi/strfmt"
	"github.com/go-openapi/swag"
)

// ResetPasswordRequestHandlerFunc turns a function with the right signature into a reset password request handler
type ResetPasswordRequestHandlerFunc func(ResetPasswordRequestParams) middleware.Responder

// Handle executing the request and returning a response
func (fn ResetPasswordRequestHandlerFunc) Handle(params ResetPasswordRequestParams) middleware.Responder {
	return fn(params)
}

// ResetPasswordRequestHandler interface for that can handle valid reset password request params
type ResetPasswordRequestHandler interface {
	Handle(ResetPasswordRequestParams) middleware.Responder
}

// NewResetPasswordRequest creates a new http.Handler for the reset password request operation
func NewResetPasswordRequest(ctx *middleware.Context, handler ResetPasswordRequestHandler) *ResetPasswordRequest {
	return &ResetPasswordRequest{Context: ctx, Handler: handler}
}

/*
	ResetPasswordRequest swagger:route POST /resetPasswordRequest account resetPasswordRequest

ResetPasswordRequest reset password request API
*/
type ResetPasswordRequest struct {
	Context *middleware.Context
	Handler ResetPasswordRequestHandler
}

func (o *ResetPasswordRequest) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	route, rCtx, _ := o.Context.RouteInfo(r)
	if rCtx != nil {
		*r = *rCtx
	}
	var Params = NewResetPasswordRequestParams()
	if err := o.Context.BindValidRequest(r, route, &Params); err != nil { // bind params
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}

	res := o.Handler.Handle(Params) // actually handle the request
	o.Context.Respond(rw, r, route.Produces, route, res)

}

// ResetPasswordRequestBody reset password request body
//
// swagger:model ResetPasswordRequestBody
type ResetPasswordRequestBody struct {

	// email address
	EmailAddress string `json:"emailAddress,omitempty"`
}

// Validate validates this reset password request body
func (o *ResetPasswordRequestBody) Validate(formats strfmt.Registry) error {
	return nil
}

// ContextValidate validates this reset password request body based on context it is used
func (o *ResetPasswordRequestBody) ContextValidate(ctx context.Context, formats strfmt.Registry) error {
	return nil
}

// MarshalBinary interface implementation
func (o *ResetPasswordRequestBody) MarshalBinary() ([]byte, error) {
	if o == nil {
		return nil, nil
	}
	return swag.WriteJSON(o)
}

// UnmarshalBinary interface implementation
func (o *ResetPasswordRequestBody) UnmarshalBinary(b []byte) error {
	var res ResetPasswordRequestBody
	if err := swag.ReadJSON(b, &res); err != nil {
		return err
	}
	*o = res
	return nil
}
