/**
 * @module montage/core/converter/new-line-to-br-converter
 * @requires montage/core/converter/converter
 */
var Converter = require("./converter").Converter,
    deprecate = require("../deprecate"),
    shouldMuteWarning = false,
    singleton;

/**
 * Replaces all new line characters with a HTML &lt;br&gt;
 * @memberof module:montage/core/converter#
 * @function
 * @param {string} str The string to format.
 * @returns {string} The formatted string.
 */
 var newLineToParagraph = function (str) {
    /*
        //To remove extra spaces after a line break:
        str.replace(/((\r\n|\r|\n)  *)/g, '<p/><p>');
    */
    return str.replace(/(\r\n|\r|\n)/g, '</p><p>');
};
var paragraphToNewLine = function (str) {
    return str.replace(/(<p\/><p>)/g, '\n');
};

/**
 * @class NewLineToParagraphConverter
 * @classdesc Converts a newline to a &lt;br&gt; tag.
 */
var NewLineToParagraphConverter = exports.NewLineToParagraphConverter = Converter.specialize({

    constructor: {
        value: function () {
            if (this.constructor === NewLineToParagraphConverter) {
                if (!singleton) {
                    singleton = this;
                }

                if (!shouldMuteWarning) {
                    deprecate.deprecationWarning(
                        "Instantiating NewLineToParagraphConverter is deprecated," +
                        " use its singleton instead"
                    );
                }

                return singleton;
            }

            return this;
        }
    },

    /**
     * @function
     * @param {string} v Case format
     * @returns this._convert(v)
     */
    convert: {
        value: function (v) {
            if (v && v !== "" & typeof v === 'string') {
                var value = newLineToParagraph(v);

                if(value !== v) {
                    value  = "<p>"+value;
                    value  += "</p>";
                    return value;
                }
            }
            return v;
        }
    },

    /**
     * @function
     * @param {string} v Case format
     * @returns this._convert(v)
     */
    revert: {
        value: function (v) {
            return paragraphToNewLine(v);
        }
    }

});

Object.defineProperty(exports, 'singleton', {
    get: function () {
        if (!singleton) {
            shouldMuteWarning = true;
            singleton = new NewLineToParagraphConverter();
            shouldMuteWarning = false;
        }

        return singleton;
    }
});
