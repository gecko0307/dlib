/*
Copyright (c) 2011-2013 Timur Gafarov 

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

module dlib.core.bst;

public:

class BST(T) 
{ 
    public this() { } 

    protected:
    BST left = null; 
    BST right = null; 
    int key = 0;

    public T value; 

    protected this(int k, T v) 
    { 
        key = k; 
        value = v; 
    } 

    public void insert(int k, T v) 
    { 
        if (k < key) 
        { 
            if (left is null) left = new BST(k, v); 
            else left.insert(k, v); 
        } 
        else if (k > key) 
        { 
            if (right is null) right = new BST(k, v); 
            else right.insert(k, v); 
        } 
        else value = v;		 
    }

    public BST find(int k) 
    { 
        if (k < key) 
        { 
            if (left !is null) return left.find(k); 
            else return null; 
        } 
        else if (k > key) 
        { 
            if (right !is null) return right.find(k); 
            else return null; 
        } 
        else return this;
    }

    protected BST findLeftMost() 
    { 
        if (left is null) return this; 
        else return left.findLeftMost(); 
    }

    public void remove(int k, BST par = null) 
    { 
        if (k < key) 
        { 
            if (left !is null) left.remove(k, this); 
            else return; 
        } 
        else if (k > key) 
        { 
            if (right !is null) right.remove(k, this); 
            else return; 
        } 
        else 
        { 
            if (left !is null && right !is null) 
            { 
                auto m = right.findLeftMost(); 
                key = m.key; 
                value = m.value; 
                right.remove(key, this); 
            } 
            else if (this == par.left) 
            { 
                par.left = (left !is null)? left : right; 
            } 
            else if (this == par.right) 
            { 
                par.right = (left !is null)? left : right; 
            } 
        } 
    }
}
