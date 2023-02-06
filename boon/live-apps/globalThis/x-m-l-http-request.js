/*
 * Copyright (c) 2018 Oracle and/or its affiliates.
 *
 * The Universal Permissive License (UPL), Version 1.0
 *
 * Subject to the condition set forth below, permission is hereby granted to any person obtaining a copy of this
 * software, associated documentation and/or data (collectively the "Software"), free of charge and under any and
 * all copyright rights in the Software, and any and all patent rights owned or freely licensable by each
 * licensor hereunder covering either (i) the unmodified Software as contributed to or provided by such licensor,
 * or (ii) the Larger Works (as defined below), to deal in both
 *
 *
 * (a) the Software, and
 *
 * (b) any piece of software and/or hardware listed in the lrgrwrks.txt file if one is included with the Software
 * (each a “Larger Work” to which the Software is contributed by such licensors),
 *
 * without restriction, including without limitation the rights to copy, create derivative works of, display,
 * perform, and distribute the Software and make, use, sell, offer for sale, import, export, have made, and
 * have sold the Software and the Larger Work(s), and to sublicense the foregoing rights on either these or other
 * terms.
 *
 * This license is subject to the following condition:
 *
 * The above copyright notice and either this complete permission notice or at a minimum a reference to the UPL
 * must be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */


/*
class List extends Array {
    constructor(...args) {
      super().push(...args);
    }
    // chainable push
    push(...args) {
      super.push(...args);
      return this;
    }
  }

  exports.List = List;

  const abc = new List('a', 'b').push('c');
  // Symbol.species by default grant same constructor
  abc.slice(2) instanceof List; // true
  console.log(abc);
  var set = new Set([1,2,3,4,5,6]);
  var other = List.from(set);
  console.log("other:",other);
  */

/*
    Inspired by https://github.com/oracle/cordova-plugin-wkwebview-file-xhr/blob/master/src/www/ios/xhr-polyfill.js
 */

const _XMLHttpRequest = globalThis.XMLHttpRequest;
const http = "http";
class XMLHttpRequest extends _XMLHttpRequest {
    //ES2019
    //#localization = "blue";

    constructor(thing) {
        super(thing);
        /*
            As soon as an instance's property value is set, even when that very property has been defined as non enumerable, on it's prototype, it's considered enumerable on that instance.
            So the only way to keep it non-enumerable is to redefine per instance, or use a shared WeakMap Instance -> Map [privateVariableName -> value]
        */
        //console.log("this.#localization",this.#localization);

//        Object.defineProperty(this, "_localization",
//        {
//            configurable: true,
//            value: undefined,
//            writable: true,
//            enumerable: false
//        });
    }
    
    get responseURL() {
        return this.__context
            ? this.__context.url
            : super.responseURL;
    }
    
    get status() {
        return this.__context
            ? this.__context.status
            : super.status;
    }
    
    set status(value) {
        return this.__context
            ? value !== this.__context.status
                ? (this.__context.status = value)
                : void 0
            : super.status = value;//Should throw an exception
    }

    get responseText() {
        return this.__context
            ? this.__context.responseText
            : super.responseText;
    }
    
    set responseText(value) {
        return this.__context
            ? value !== this.__context.responseText
                ? (this.__context.responseText = value)
                : void 0
            : super.responseText = value;//Should throw an exception
    }


    bridgeOpen(method, url, async, user, password) {
        var _context = this._context;
        _context.method = !method ? "GET" : method.toUpperCase();  // FortifyFalsePositive
        _context.url = url;
        _context.async = async === undefined ? true : async;
        _context.user = user;
        _context.password = password;
    }
    
    open(method, url, async, user, password) {
        return url.startsWith(http)
            ? super.open(method, url, async, user, password)
            : this.bridgeOpen(method, url, async, user, password);
    }

    bridgeSend(data) {
        if ("GET" !== this._context.method && "HEAD" !== this._context.method)
          this._context.requestData = data;

        /* special case for xhr created by require()*/
        if(this.module) {
            this._context.factoryDisplayName =  this.module.factoryDisplayName;
        }
        let promise = window.webkit.messageHandlers.httpRequestDelegate.postMessage(this._context)
        
        promise.then(
         (result) => {
             //console.log('>>>> bridgeSend result', result);
             this.status = 200;
             this.responseText = result;
             
             /*
                  See https://developer.mozilla.org/en-US/docs/Web/API/ProgressEvent/ProgressEvent
                  This is currently a simplificaion for text only
              */
             let loadEvent = new ProgressEvent("load", {
                 lengthComputable: true,
                 loaded: result.length,
                 total: result.length
             });
             //console.log('loadEvent:', loadEvent);
             this.dispatchEvent(loadEvent);
         },
         (err) => {
             console.log(err)
           }
        )

    }

    send(body) {
        //console.debug(">>>> overriden send()");
        return this.__context
            ? this.bridgeSend(body)
            : super.send(body);
      }

    
};


Object.defineProperty(XMLHttpRequest.prototype, "__context", {
    value: undefined,
    writable: true,
    enumerable: false
});

Object.defineProperty(XMLHttpRequest.prototype, "_context", {
    set: function(value) {
        this.__context = value;
    },
    get: function() {
        return this.__context || (
         this.__context =  {
            delegate: null,
            requestHeaders: {},
            responseHeaders: {},
            readyState: 0,
            responseType: "text",
            withCredentials: false,
            upload: null/*new _XMLHttpRequestUpload()*/,
             status: 0
         });
    },
    enumerable: false
});

globalThis.XMLHttpRequest  = XMLHttpRequest;

/*

configurable: true
enumerable: false
value: undefined
writable: true

*/
//Object.defineProperty(LocalizedString, "_defaultLocale", {
//    value: undefined
//});
//
//Object.defineProperty(LocalizedString, "defaultLocale", {
//    set: function(value) {
//        this._defaultLocale = value;
//    },
//    get: function() {
//        return this._defaultLocale || Locale.systenLocale;
//    }
//});

/*
    This changes the locale of all LocalizedString
    that haven't been set directly a locale that would
    override the prototype's default value
*/

//Object.defineProperty(LocalizedString.prototype, "localization", {
//    set: function(value) {
//        this._localization = value;
//    },
//    get: function() {
//        return this._localization;
//    }
//});
//
//Object.defineProperty(LocalizedString, "locale", {
//    set: function(value) {
//        this.prototype._locale = value;
//    },
//    get: function() {
//        return this.prototype._locale || this.defaultLocale;
//    }
//});
//
//
//Object.defineProperty(LocalizedString.prototype, "locale", {
//    set: function(value) {
//        this._locale = value;
//    },
//    get: function() {
//        return this._locale || LocalizedString.defaultLocale;
//    }
//});
