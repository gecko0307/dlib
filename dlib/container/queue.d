/*
Copyright (c) 2011-2017 Timur Gafarov 

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

module dlib.container.queue;

private
{ 
    import dlib.container.linkedlist;
}

public:

/**
 * Queue implementation based on LinkedList.
 */
struct Queue(T)
{
private:
    LinkedList!(T, true) list;
public:
    /**
     * Check if stack has no elements.
     */
    @property bool empty()
    {
        return list.empty;
    }

    /**
     * Add element to queue.
     */
    void enqueue(T v)
    {
        list.append(v);
    }

    /**
     * Remove element from queue.
     * Returns: Removed element.
     * Throws: Exception if queue is empty.
     */
    T dequeue()
    {
        if (empty)
            throw new Exception("Queue!(T): queue is empty");

        T res = list.head.datum;
        list.removeBeginning();
        return res;
    }
    
    /**
     * Free memory allocated by Queue.
     */
    void free()
    {
        list.free();
    }
}

///
unittest
{
    import std.exception : assertThrown;
    
    Queue!int q;
    assertThrown(q.dequeue());
    assert (q.empty);

    q.enqueue(50);
    q.enqueue(30);
    q.enqueue(900);

    assert (q.dequeue() == 50);
    assert (q.dequeue() == 30);
    assert (q.dequeue() == 900);
    assert (q.empty);
    
    q.free();
}
