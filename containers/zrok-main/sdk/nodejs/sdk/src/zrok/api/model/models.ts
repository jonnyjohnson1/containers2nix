import localVarRequest from 'request';

export * from './accessRequest';
export * from './accessResponse';
export * from './authUser';
export * from './changePasswordRequest';
export * from './configuration';
export * from './createAccountRequest';
export * from './createFrontendRequest';
export * from './createFrontendResponse';
export * from './createIdentity201Response';
export * from './createIdentityRequest';
export * from './deleteFrontendRequest';
export * from './disableRequest';
export * from './enableRequest';
export * from './enableResponse';
export * from './environment';
export * from './environmentAndResources';
export * from './frontend';
export * from './grantsRequest';
export * from './inviteRequest';
export * from './inviteTokenGenerateRequest';
export * from './loginRequest';
export * from './metrics';
export * from './metricsSample';
export * from './overview';
export * from './passwordRequirements';
export * from './principal';
export * from './publicFrontend';
export * from './regenerateToken200Response';
export * from './regenerateTokenRequest';
export * from './registerRequest';
export * from './registerResponse';
export * from './resetPasswordRequest';
export * from './share';
export * from './shareRequest';
export * from './shareResponse';
export * from './sparkDataSample';
export * from './unaccessRequest';
export * from './unshareRequest';
export * from './updateFrontendRequest';
export * from './updateShareRequest';
export * from './verifyRequest';
export * from './verifyResponse';

import * as fs from 'fs';

export interface RequestDetailedFile {
    value: Buffer;
    options?: {
        filename?: string;
        contentType?: string;
    }
}

export type RequestFile = string | Buffer | fs.ReadStream | RequestDetailedFile;


import { AccessRequest } from './accessRequest';
import { AccessResponse } from './accessResponse';
import { AuthUser } from './authUser';
import { ChangePasswordRequest } from './changePasswordRequest';
import { Configuration } from './configuration';
import { CreateAccountRequest } from './createAccountRequest';
import { CreateFrontendRequest } from './createFrontendRequest';
import { CreateFrontendResponse } from './createFrontendResponse';
import { CreateIdentity201Response } from './createIdentity201Response';
import { CreateIdentityRequest } from './createIdentityRequest';
import { DeleteFrontendRequest } from './deleteFrontendRequest';
import { DisableRequest } from './disableRequest';
import { EnableRequest } from './enableRequest';
import { EnableResponse } from './enableResponse';
import { Environment } from './environment';
import { EnvironmentAndResources } from './environmentAndResources';
import { Frontend } from './frontend';
import { GrantsRequest } from './grantsRequest';
import { InviteRequest } from './inviteRequest';
import { InviteTokenGenerateRequest } from './inviteTokenGenerateRequest';
import { LoginRequest } from './loginRequest';
import { Metrics } from './metrics';
import { MetricsSample } from './metricsSample';
import { Overview } from './overview';
import { PasswordRequirements } from './passwordRequirements';
import { Principal } from './principal';
import { PublicFrontend } from './publicFrontend';
import { RegenerateToken200Response } from './regenerateToken200Response';
import { RegenerateTokenRequest } from './regenerateTokenRequest';
import { RegisterRequest } from './registerRequest';
import { RegisterResponse } from './registerResponse';
import { ResetPasswordRequest } from './resetPasswordRequest';
import { Share } from './share';
import { ShareRequest } from './shareRequest';
import { ShareResponse } from './shareResponse';
import { SparkDataSample } from './sparkDataSample';
import { UnaccessRequest } from './unaccessRequest';
import { UnshareRequest } from './unshareRequest';
import { UpdateFrontendRequest } from './updateFrontendRequest';
import { UpdateShareRequest } from './updateShareRequest';
import { VerifyRequest } from './verifyRequest';
import { VerifyResponse } from './verifyResponse';

/* tslint:disable:no-unused-variable */
let primitives = [
                    "string",
                    "boolean",
                    "double",
                    "integer",
                    "long",
                    "float",
                    "number",
                    "any"
                 ];

let enumsMap: {[index: string]: any} = {
        "CreateFrontendRequest.PermissionModeEnum": CreateFrontendRequest.PermissionModeEnum,
        "ShareRequest.ShareModeEnum": ShareRequest.ShareModeEnum,
        "ShareRequest.BackendModeEnum": ShareRequest.BackendModeEnum,
        "ShareRequest.OauthProviderEnum": ShareRequest.OauthProviderEnum,
        "ShareRequest.PermissionModeEnum": ShareRequest.PermissionModeEnum,
}

let typeMap: {[index: string]: any} = {
    "AccessRequest": AccessRequest,
    "AccessResponse": AccessResponse,
    "AuthUser": AuthUser,
    "ChangePasswordRequest": ChangePasswordRequest,
    "Configuration": Configuration,
    "CreateAccountRequest": CreateAccountRequest,
    "CreateFrontendRequest": CreateFrontendRequest,
    "CreateFrontendResponse": CreateFrontendResponse,
    "CreateIdentity201Response": CreateIdentity201Response,
    "CreateIdentityRequest": CreateIdentityRequest,
    "DeleteFrontendRequest": DeleteFrontendRequest,
    "DisableRequest": DisableRequest,
    "EnableRequest": EnableRequest,
    "EnableResponse": EnableResponse,
    "Environment": Environment,
    "EnvironmentAndResources": EnvironmentAndResources,
    "Frontend": Frontend,
    "GrantsRequest": GrantsRequest,
    "InviteRequest": InviteRequest,
    "InviteTokenGenerateRequest": InviteTokenGenerateRequest,
    "LoginRequest": LoginRequest,
    "Metrics": Metrics,
    "MetricsSample": MetricsSample,
    "Overview": Overview,
    "PasswordRequirements": PasswordRequirements,
    "Principal": Principal,
    "PublicFrontend": PublicFrontend,
    "RegenerateToken200Response": RegenerateToken200Response,
    "RegenerateTokenRequest": RegenerateTokenRequest,
    "RegisterRequest": RegisterRequest,
    "RegisterResponse": RegisterResponse,
    "ResetPasswordRequest": ResetPasswordRequest,
    "Share": Share,
    "ShareRequest": ShareRequest,
    "ShareResponse": ShareResponse,
    "SparkDataSample": SparkDataSample,
    "UnaccessRequest": UnaccessRequest,
    "UnshareRequest": UnshareRequest,
    "UpdateFrontendRequest": UpdateFrontendRequest,
    "UpdateShareRequest": UpdateShareRequest,
    "VerifyRequest": VerifyRequest,
    "VerifyResponse": VerifyResponse,
}

export class ObjectSerializer {
    public static findCorrectType(data: any, expectedType: string) {
        if (data == undefined) {
            return expectedType;
        } else if (primitives.indexOf(expectedType.toLowerCase()) !== -1) {
            return expectedType;
        } else if (expectedType === "Date") {
            return expectedType;
        } else {
            if (enumsMap[expectedType]) {
                return expectedType;
            }

            if (!typeMap[expectedType]) {
                return expectedType; // w/e we don't know the type
            }

            // Check the discriminator
            let discriminatorProperty = typeMap[expectedType].discriminator;
            if (discriminatorProperty == null) {
                return expectedType; // the type does not have a discriminator. use it.
            } else {
                if (data[discriminatorProperty]) {
                    var discriminatorType = data[discriminatorProperty];
                    if(typeMap[discriminatorType]){
                        return discriminatorType; // use the type given in the discriminator
                    } else {
                        return expectedType; // discriminator did not map to a type
                    }
                } else {
                    return expectedType; // discriminator was not present (or an empty string)
                }
            }
        }
    }

    public static serialize(data: any, type: string) {
        if (data == undefined) {
            return data;
        } else if (primitives.indexOf(type.toLowerCase()) !== -1) {
            return data;
        } else if (type.lastIndexOf("Array<", 0) === 0) { // string.startsWith pre es6
            let subType: string = type.replace("Array<", ""); // Array<Type> => Type>
            subType = subType.substring(0, subType.length - 1); // Type> => Type
            let transformedData: any[] = [];
            for (let index = 0; index < data.length; index++) {
                let datum = data[index];
                transformedData.push(ObjectSerializer.serialize(datum, subType));
            }
            return transformedData;
        } else if (type === "Date") {
            return data.toISOString();
        } else {
            if (enumsMap[type]) {
                return data;
            }
            if (!typeMap[type]) { // in case we dont know the type
                return data;
            }

            // Get the actual type of this object
            type = this.findCorrectType(data, type);

            // get the map for the correct type.
            let attributeTypes = typeMap[type].getAttributeTypeMap();
            let instance: {[index: string]: any} = {};
            for (let index = 0; index < attributeTypes.length; index++) {
                let attributeType = attributeTypes[index];
                instance[attributeType.baseName] = ObjectSerializer.serialize(data[attributeType.name], attributeType.type);
            }
            return instance;
        }
    }

    public static deserialize(data: any, type: string) {
        // polymorphism may change the actual type.
        type = ObjectSerializer.findCorrectType(data, type);
        if (data == undefined) {
            return data;
        } else if (primitives.indexOf(type.toLowerCase()) !== -1) {
            return data;
        } else if (type.lastIndexOf("Array<", 0) === 0) { // string.startsWith pre es6
            let subType: string = type.replace("Array<", ""); // Array<Type> => Type>
            subType = subType.substring(0, subType.length - 1); // Type> => Type
            let transformedData: any[] = [];
            for (let index = 0; index < data.length; index++) {
                let datum = data[index];
                transformedData.push(ObjectSerializer.deserialize(datum, subType));
            }
            return transformedData;
        } else if (type === "Date") {
            return new Date(data);
        } else {
            if (enumsMap[type]) {// is Enum
                return data;
            }

            if (!typeMap[type]) { // dont know the type
                return data;
            }
            let instance = new typeMap[type]();
            let attributeTypes = typeMap[type].getAttributeTypeMap();
            for (let index = 0; index < attributeTypes.length; index++) {
                let attributeType = attributeTypes[index];
                instance[attributeType.name] = ObjectSerializer.deserialize(data[attributeType.baseName], attributeType.type);
            }
            return instance;
        }
    }
}

export interface Authentication {
    /**
    * Apply authentication settings to header and query params.
    */
    applyToRequest(requestOptions: localVarRequest.Options): Promise<void> | void;
}

export class HttpBasicAuth implements Authentication {
    public username: string = '';
    public password: string = '';

    applyToRequest(requestOptions: localVarRequest.Options): void {
        requestOptions.auth = {
            username: this.username, password: this.password
        }
    }
}

export class HttpBearerAuth implements Authentication {
    public accessToken: string | (() => string) = '';

    applyToRequest(requestOptions: localVarRequest.Options): void {
        if (requestOptions && requestOptions.headers) {
            const accessToken = typeof this.accessToken === 'function'
                            ? this.accessToken()
                            : this.accessToken;
            requestOptions.headers["Authorization"] = "Bearer " + accessToken;
        }
    }
}

export class ApiKeyAuth implements Authentication {
    public apiKey: string = '';

    constructor(private location: string, private paramName: string) {
    }

    applyToRequest(requestOptions: localVarRequest.Options): void {
        if (this.location == "query") {
            (<any>requestOptions.qs)[this.paramName] = this.apiKey;
        } else if (this.location == "header" && requestOptions && requestOptions.headers) {
            requestOptions.headers[this.paramName] = this.apiKey;
        } else if (this.location == 'cookie' && requestOptions && requestOptions.headers) {
            if (requestOptions.headers['Cookie']) {
                requestOptions.headers['Cookie'] += '; ' + this.paramName + '=' + encodeURIComponent(this.apiKey);
            }
            else {
                requestOptions.headers['Cookie'] = this.paramName + '=' + encodeURIComponent(this.apiKey);
            }
        }
    }
}

export class OAuth implements Authentication {
    public accessToken: string = '';

    applyToRequest(requestOptions: localVarRequest.Options): void {
        if (requestOptions && requestOptions.headers) {
            requestOptions.headers["Authorization"] = "Bearer " + this.accessToken;
        }
    }
}

export class VoidAuth implements Authentication {
    public username: string = '';
    public password: string = '';

    applyToRequest(_: localVarRequest.Options): void {
        // Do nothing
    }
}

export type Interceptor = (requestOptions: localVarRequest.Options) => (Promise<void> | void);
