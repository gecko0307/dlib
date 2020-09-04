/*
Copyright (c) 2016-2020 Timur Gafarov

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

/**
 * General-purpose non-allocating lexical analyzer.
 *
 * Description:
 * Breaks the input string to a stream of lexemes according to a given delimiter dictionary.
 * Delimiters are symbols that separate sequences of characters (e.g. operators).
 * Lexemes are slices of the input string.
 * Assumes UTF-8 input.
 * Treats \r\n as a single \n.
 *
 * Copyright: Timur Gafarov 2016-2020.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov, Eugene Wissner, Roman Chistokhodov, ijet
 */
module dlib.text.lexer;

import std.ascii;
import std.range.interfaces;
import dlib.text.utf8;

/**
 * Lexical analyzer class
 */
class Lexer: InputRange!string
{
    protected:
    string input;
    string[] delims;

    UTF8Decoder dec;
    uint index;
    dchar current;
    uint currentSize;

    public:
    bool ignoreWhitespaces = false;
    bool ignoreNewlines = false;

    this(string input, string[] delims)
    {
        this.input = input;
        this.delims = delims;
        this.dec.input = this.input;
        this.index = 0;
        advance();
    }
    
    uint position() @property
    {
        return pos();
    }

    string getLexeme()
    {
        string res = "";
        int tStart = -1;
        while(true)
        {
            dchar c = current;
            if (c == UTF8_END || c == UTF8_ERROR)
            {
                if (tStart > -1)
                {
                    res = input[tStart..pos];
                    tStart = -1;
                    break;
                }
                else
                {
                    res = "";
                    break;
                }
            }

            if (isNewline(c)) 
            {
                if (tStart > -1)
                {
                    res = input[tStart..pos];
                    tStart = -1;
                    break;
                }
                else
                {
                    if (c == '\r')
                    {
                        advance();
                        c = current;
                        if (c == '\n')
                            advance();
                    }
                    else
                    {
                        advance();
                    }

                    if (ignoreNewlines)
                    {
                        continue;
                    }
                    else
                    {
                        res = "\n";
                        break;
                    }
                }
            }

            if (isWhitespace(c))
            {
                if (tStart > -1)
                {
                    res = input[tStart..pos];
                    tStart = -1;
                    break;
                }
                else
                {
                    advance();
                    if (ignoreWhitespaces)
                    {
                        continue;
                    }
                    else
                    {
                        res = " ";
                        break;
                    }
                }
            }

            string d = consumeDelimiter();
            if (d.length)
            {
                if (tStart > -1)
                {
                    res = input[tStart..pos];
                }
                else
                {
                    res = d;
                    forwardJump(d.length);
                }

                break;
            }
            else
            {
                if (tStart == -1)
                {
                    tStart = pos;
                }
                advance();
            }
        }

        return res;
    }

    protected:

    uint pos()
    {
        return index-currentSize;
    }

    void advance()
    {
        current = dec.decodeNext();
        currentSize = cast(uint)dec.index - index;
        index += currentSize;
    }

    void forwardJump(size_t numChars)
    {
        for(size_t i = 0; i < numChars; i++)
        {
            advance();
        }
    }

    bool forwardCompare(string str)
    {
        UTF8Decoder dec2 = UTF8Decoder(str);
        size_t oldIndex = dec.index;

        bool res = true;

        int c1 = current;
        int c2 = dec2.decodeNext();
        do
        {
            if (c2 == UTF8_END || c2 == UTF8_ERROR)
                break;

            if (c1 == UTF8_END && c2 == UTF8_END)
            {
                res = true;
                break;
            }

            if (c1 != UTF8_END && c1 != UTF8_ERROR &&
                c2 != UTF8_END && c2 != UTF8_ERROR)
            {
                if (c1 != c2)
                {
                    res = false;
                    break;
                }
            }
            else
            {
                res = false;
                break;
            }

            c1 = dec.decodeNext();
            c2 = dec2.decodeNext();
        }
        while(c2 != UTF8_END && c2 != UTF8_ERROR);

        dec.index = oldIndex;

        return res;
    }

    bool isWhitespace(dchar c)
    {
        foreach(w; std.ascii.whitespace)
        {
            if (c == w)
            {
                return true;
            }
        }
        return false;
    }

    bool isNewline(dchar c)
    {
        return (c == '\n' || c == '\r');
    }

    string consumeDelimiter()
    {
        size_t bestLen = 0;
        string bestStr = "";
        foreach(d; delims)
        {
            if (forwardCompare(d))
            {
                if (d.length > bestLen)
                {
                    bestLen = d.length;
                    bestStr = input[pos..pos+d.length];
                }
            }
        }
        return bestStr;
    }

    // Range interface

    private:

    string _front;

    public:

    bool empty()
    {
        return _front.length == 0;
    }

    string front()
    {
        return _front;
    }

    void popFront()
    {
        _front = getLexeme();
    }

    string moveFront()
    {
        _front = getLexeme();
        return _front;
    }

    int opApply(scope int delegate(string) dg)
    {
        int result = 0;

        while(true)
        {
            string lexeme = getLexeme();

            if (!lexeme.length)
                break;

            result = dg(lexeme);
            if (result)
                break;
        }

        return result;
    }

    int opApply(scope int delegate(size_t, string) dg)
    {
        int result = 0;
        size_t i = 0;

        while(true)
        {
            string lexeme = getLexeme();

            if (!lexeme.length)
                break;

            result = dg(i, lexeme);
            if (result)
                break;

            i++;
        }

        return result;
    }
}

///
unittest
{
    string[] delims = ["(", ")", ";", " ", "{", "}", ".", "\n", "\r", "=", "++", "<"];
    auto input = "for (int i=0; i<arr.length; ++i)\r\n{doThing();}\n";
    auto lexer = new Lexer(input, delims);

    string[] arr;
    while(true) {
        auto lexeme = lexer.getLexeme();
        if(lexeme.length == 0) {
            break;
        }
        arr ~= lexeme;
    }
    assert(arr == [
        "for", " ", "(", "int", " ", "i", "=", "0", ";", " ", "i", "<",
        "arr", ".", "length", ";", " ", "++", "i", ")", "\n", "{", "doThing",
        "(", ")", ";", "}", "\n" ]);

    input = "";
    lexer = new Lexer(input, delims);
    assert(lexer.getLexeme().length == 0);
}
