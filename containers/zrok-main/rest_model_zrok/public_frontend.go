// Code generated by go-swagger; DO NOT EDIT.

package rest_model_zrok

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"context"

	"github.com/go-openapi/strfmt"
	"github.com/go-openapi/swag"
)

// PublicFrontend public frontend
//
// swagger:model publicFrontend
type PublicFrontend struct {

	// created at
	CreatedAt int64 `json:"createdAt,omitempty"`

	// public name
	PublicName string `json:"publicName,omitempty"`

	// token
	Token string `json:"token,omitempty"`

	// updated at
	UpdatedAt int64 `json:"updatedAt,omitempty"`

	// url template
	URLTemplate string `json:"urlTemplate,omitempty"`

	// z Id
	ZID string `json:"zId,omitempty"`
}

// Validate validates this public frontend
func (m *PublicFrontend) Validate(formats strfmt.Registry) error {
	return nil
}

// ContextValidate validates this public frontend based on context it is used
func (m *PublicFrontend) ContextValidate(ctx context.Context, formats strfmt.Registry) error {
	return nil
}

// MarshalBinary interface implementation
func (m *PublicFrontend) MarshalBinary() ([]byte, error) {
	if m == nil {
		return nil, nil
	}
	return swag.WriteJSON(m)
}

// UnmarshalBinary interface implementation
func (m *PublicFrontend) UnmarshalBinary(b []byte) error {
	var res PublicFrontend
	if err := swag.ReadJSON(b, &res); err != nil {
		return err
	}
	*m = res
	return nil
}
