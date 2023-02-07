/*
Copyright (c) 2013-2023 Timur Gafarov

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
 * Copyright: Timur Gafarov 2013-2023.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.geometry.trimesh;

import std.stdio;
import std.math;

import dlib.core.memory;
import dlib.container.array;
import dlib.math.vector;
import dlib.geometry.triangle;

struct Index
{
    uint a, b, c;
}

struct FaceGroup
{
    Array!Index indicesArray;
    int materialIndex;

    @property Index[] indices() { return indicesArray.data; }

    void addFace(uint a, uint b, uint c)
    {
        indicesArray.insertBack(Index(a, b, c));
    }

    void addFaces(Index[] inds)
    {
        indicesArray.insertBack(inds);
    }
}

/// Triangle mesh
class TriMesh
{
    Array!(Vector3f) verticesArray;
    Array!(Vector3f) normalsArray;
    Array!(Vector3f) tangentsArray;
    Array!(Vector2f) texcoordsArray;

    Array!FaceGroup facegroupsArray;

    @property Vector3f[] vertices()   { return verticesArray.data; }
    @property Vector3f[] normals()    { return normalsArray.data; }
    @property Vector3f[] tangents()   { return tangentsArray.data; }
    @property Vector2f[] texcoords()  { return texcoordsArray.data; }
    @property FaceGroup[] facegroups() { return facegroupsArray.data; }

    this()
    {
    }

    ~this()
    {
        verticesArray.free();
        normalsArray.free();
        tangentsArray.free();
        texcoordsArray.free();

        foreach(fc; facegroupsArray)
            fc.indicesArray.free();
        facegroupsArray.free();
    }

    void addVertex(Vector3f v)
    {
        verticesArray.insertBack(v);
    }

    void addNormal(Vector3f n)
    {
        normalsArray.insertBack(n);
    }

    void addTangent(Vector3f t)
    {
        tangentsArray.insertBack(t);
    }

    void addTexcoord(Vector2f t)
    {
        texcoordsArray.insertBack(t);
    }

    void addVertices(Vector3f[] verts)
    {
        verticesArray.insertBack(verts);
    }

    void addNormals(Vector3f[] norms)
    {
        normalsArray.insertBack(norms);
    }

    void addTangents(Vector3f[] tans)
    {
        tangentsArray.insertBack(tans);
    }

    void addTexcoords(Vector2f[] texs)
    {
        texcoordsArray.insertBack(texs);
    }

    FaceGroup* addFacegroup()
    {
        FaceGroup fg;
        facegroupsArray.insertBack(fg);
        return &facegroupsArray.data[$-1];
    }

    Triangle getTriangle(uint facegroupIndex, uint triIndex)
    {
        Triangle tri;
        Index triIdx = facegroupsArray[facegroupIndex].indicesArray[triIndex];

        tri.v[0] = verticesArray[triIdx.a];
        tri.v[1] = verticesArray[triIdx.b];
        tri.v[2] = verticesArray[triIdx.c];

        tri.n[0] = normalsArray[triIdx.a];
        tri.n[1] = normalsArray[triIdx.b];
        tri.n[2] = normalsArray[triIdx.c];

        if (texcoordsArray.length == verticesArray.length)
        {
            tri.t1[0] = texcoordsArray[triIdx.a];
            tri.t1[1] = texcoordsArray[triIdx.b];
            tri.t1[2] = texcoordsArray[triIdx.c];
        }

        tri.normal = planeNormal(tri.v[0], tri.v[1], tri.v[2]);

        tri.barycenter = (tri.v[0] + tri.v[1] + tri.v[2]) / 3;

        tri.d = (tri.v[0].x * tri.normal.x +
                 tri.v[0].y * tri.normal.y +
                 tri.v[0].z * tri.normal.z);

        tri.edges[0] = tri.v[1] - tri.v[0];
        tri.edges[1] = tri.v[2] - tri.v[1];
        tri.edges[2] = tri.v[0] - tri.v[2];

        tri.materialIndex = facegroupsArray[facegroupIndex].materialIndex;

        return tri;
    }

    /**
     * Read-only triangle aggregate
     */
    int opApply(scope int delegate(ref Triangle) dg)
    {
        int result = 0;
        for (uint fgi = 0; fgi < facegroupsArray.length; fgi++)
        for (uint i = 0; i < facegroupsArray[fgi].indices.length; i++)
        {
            Triangle tri = getTriangle(fgi, i);
            result = dg(tri);
            if (result)
                break;
        }
        return result;
    }

    void genTangents()
    {
        tangentsArray.free();

        Vector3f[] sTan = New!(Vector3f[])(verticesArray.length);
        Vector3f[] tTan = New!(Vector3f[])(verticesArray.length);

        foreach(i, v; sTan)
        {
            sTan[i] = Vector3f(0.0f, 0.0f, 0.0f);
            tTan[i] = Vector3f(0.0f, 0.0f, 0.0f);
        }

        foreach(ref fg; facegroupsArray)
        foreach(ref index; fg.indicesArray)
        {
            uint i0 = index.a;
            uint i1 = index.b;
            uint i2 = index.c;

            Vector3f v0 = verticesArray[i0];
            Vector3f v1 = verticesArray[i1];
            Vector3f v2 = verticesArray[i2];

            Vector2f w0 = texcoordsArray[i0];
            Vector2f w1 = texcoordsArray[i1];
            Vector2f w2 = texcoordsArray[i2];

            float x1 = v1.x - v0.x;
            float x2 = v2.x - v0.x;
            float y1 = v1.y - v0.y;
            float y2 = v2.y - v0.y;
            float z1 = v1.z - v0.z;
            float z2 = v2.z - v0.z;

            float s1 = w1[0] - w0[0];
            float s2 = w2[0] - w0[0];
            float t1 = w1[1] - w0[1];
            float t2 = w2[1] - w0[1];

            float r = (s1 * t2) - (s2 * t1);

            // Prevent division by zero
            if (r == 0.0f)
                r = 1.0f;

            float oneOverR = 1.0f / r;

            Vector3f sDir = Vector3f((t2 * x1 - t1 * x2) * oneOverR,
                                     (t2 * y1 - t1 * y2) * oneOverR,
                                     (t2 * z1 - t1 * z2) * oneOverR);
            Vector3f tDir = Vector3f((s1 * x2 - s2 * x1) * oneOverR,
                                     (s1 * y2 - s2 * y1) * oneOverR,
                                     (s1 * z2 - s2 * z1) * oneOverR);

            sTan[i0] += sDir;
            tTan[i0] += tDir;

            sTan[i1] += sDir;
            tTan[i1] += tDir;

            sTan[i2] += sDir;
            tTan[i2] += tDir;
        }

        tangentsArray.resize(vertices.length, Vector3f(0.0f, 0.0f, 0.0f));

        // Calculate vertex tangent
        foreach(i, v; tangents)
        {
            Vector3f n = normalsArray[i];
            Vector3f t = sTan[i];

            // Gram-Schmidt orthogonalize
            Vector3f tangent = (t - n * dot(n, t));
            tangent.normalize();
            tangentsArray[i] = tangent;
        }

        Delete(sTan);
        Delete(tTan);
    }
}
