/*
Copyright (c) 2019-2023 Timur Gafarov

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
 * Copyright: Timur Gafarov 2019-2023.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.concurrency.workerthread;

import dlib.core.thread;
import dlib.concurrency.threadpool;
import dlib.concurrency.taskqueue;

/**
 * A thread that is created by ThreadPool
 */
class WorkerThread: Thread
{
    size_t id;
    ThreadPool pool;
    protected bool _busy = false;

    /// Constructor
    this(size_t id, ThreadPool pool)
    {
        super(&threadFunc);
        this.id = id;
        this.pool = pool;
    }

    bool busy()
    {
        return _busy;
    }

    protected void threadFunc()
    {
        while(pool.isRunning)
        {
            Task task = pool.request();
            if (task.state != TaskState.Invalid)
            {
                _busy = true;
                task.run();
                _busy = false;
            }
        }
    }
}
