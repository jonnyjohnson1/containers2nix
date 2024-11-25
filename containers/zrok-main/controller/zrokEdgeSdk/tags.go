package zrokEdgeSdk

import (
	"github.com/openziti/edge-api/rest_model"
	"github.com/openziti/zrok/build"
)

func ZrokTags() *rest_model.Tags {
	return &rest_model.Tags{
		SubTags: map[string]interface{}{
			"zrok": build.String(),
		},
	}
}

func ZrokShareTags(shrToken string) *rest_model.Tags {
	tags := ZrokTags()
	tags.SubTags["zrokShareToken"] = shrToken
	return tags
}

func MergeTags(tags *rest_model.Tags, addl map[string]interface{}) *rest_model.Tags {
	for k, v := range addl {
		tags.SubTags[k] = v
	}
	return tags
}
