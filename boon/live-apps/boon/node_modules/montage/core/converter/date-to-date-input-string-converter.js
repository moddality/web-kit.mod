/**
 * @module montage/core/converter/lower-case-converter
 * @requires montage/core/converter/converter
 */
var Converter = require("./converter").Converter,
    deprecate = require("../deprecate"),
    shouldMuteWarning = false,
    singleton;

/**
 * @class DateToDateInputStringConverter
 * https://webreflection.medium.com/using-the-input-datetime-local-9503e7efdce
 * @classdesc Converts a Date instance to the string format expected by an <input type="date"> .
 */
var DateToDateInputStringConverter = exports.DateToDateInputStringConverter = Converter.specialize({

    constructor: {
        value: function () {
            if (this.constructor === DateToDateInputStringConverter) {
                if (!singleton) {
                    singleton = this;
                }

                if (!shouldMuteWarning) {
                    deprecate.deprecationWarning(
                        "Instantiating DateToDateInputStringConverter is deprecated," +
                        " use its singleton instead"
                    );
                }

                return singleton;
            }

            return this;
        }
    },

    _ten: {
        value: function (i) {
            return (i < 10 ? '0' : '') + i;
        }
    },

    inputsTime: {
        value: false
    },

    allowPartialConversion: {
        value: false
    },

    /**
     * @function
     * @param {string} v Case format
     * @returns this._convert(v)
     */
    convert: {
        value: function (v) {

            if(v) {
                var result = v.getFullYear();

                if(isNaN(result)) {
                    return null;
                }

                result +=  '-';
                result +=  this._ten(v.getMonth() + 1);
                result +=  '-';
                result +=  this._ten(v.getDate());

                return result;
            } else {
                return null;
            }
        }
    },

    /**
     * @function
     * @param {string} v Case format
     * @returns this._convert(v)
     */
    revert: {
        value: function(v) {
            var vParts = v.split("-");
            return new Date(vParts[0], vParts[1]-1, vParts[2]);
        }
    }
});

Object.defineProperty(exports, 'singleton', {
    get: function () {
        if (!singleton) {
            shouldMuteWarning = true;
            singleton = new DateToDateInputStringConverter();
            shouldMuteWarning = false;
        }

        return singleton;
    }
});
