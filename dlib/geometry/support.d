/*
Copyright (c) 2011-2023 Timur Gafarov

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
 * Copyright: Timur Gafarov 2011-2023.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.geometry.support;

import std.math;
import dlib.math.vector;
import dlib.math.matrix;
import dlib.math.utils;

/// Sphere support function
Vector3f supSphere(Vector3f dir, float radius)
{
    return dir * radius;
}

/// Ellipsoid support function
Vector3f supEllipsoid(Vector3f dir, Vector3f radii)
{
    return dir * radii;
}

/// AABB support function
Vector3f subBox(Vector3f dir, Vector3f halfSize)
{
    Vector3f result;
    result.x = sign(dir.x) * halfSize.x;
    result.y = sign(dir.y) * halfSize.y;
    result.z = sign(dir.z) * halfSize.z;
    return result;
}

/// Cylinder support function
Vector3f supCylinder(Vector3f dir, float radius, float height)
{
    Vector3f result;
    float sigma = sqrt((dir.x * dir.x + dir.z * dir.z));

    if (sigma > 0.0f)
    {
        result.x = dir.x / sigma * radius;
        result.y = sign(dir.y) * height * 0.5f;
        result.z = dir.z / sigma * radius;
    }
    else
    {
        result.x = 0.0f;
        result.y = sign(dir.y) * height * 0.5f;
        result.z = 0.0f;
    }

    return result;
}

/// Cone support function
Vector3f supCone(Vector3f dir, float radius, float height)
{
    float zdist = dir[0] * dir[0] + dir[1] * dir[1];
    float len = zdist + dir[2] * dir[2];
    zdist = sqrt(zdist);
    len = sqrt(len);
    float half_h = height * 0.5;

    float sin_a = radius / sqrt(radius * radius + 4.0f * half_h * half_h);

    if (dir[2] > len * sin_a)
        return Vector3f(0.0f, 0.0f, half_h);
    else if (zdist > 0.0f)
    {
        float rad = radius / zdist;
        return Vector3f(rad * dir[0], rad * dir[1], -half_h);
    }
    else
        return Vector3f(0.0f, 0.0f, -half_h);
}

/// Capsule support function
Vector3f supCapsule(Vector3f dir, float radius, float height)
{
    float half_h = height * 0.5f;
    Vector3f pos1 = Vector3f(0.0f, 0.0f, half_h);
    Vector3f pos2 = Vector3f(0.0f, 0.0f, -half_h);
    Vector3f v = dir * radius;
    pos1 += v;
    pos2 += v;
    if (dir.dot(pos1) > dir.dot(pos2))
        return pos1;
    else return pos2;
}

/// Convex hull support function
Vector3f supConvexHull(Vector3f dir, Vector3f[] vertices)
{
    float maxdot = -float.max;
    Vector3f bestv;
    foreach(v; vertices)
    {
        float d = dir.dot(v);
        if (d > maxdot)
        {
            bestv = v;
            maxdot = d;
        }
    }
    return bestv;
}

/// Triangle support function
Vector3f supTriangle(Vector3f dir, Vector3f[3] v)
{
    float dota = dir.dot(v[0]);
    float dotb = dir.dot(v[1]);
    float dotc = dir.dot(v[2]);

    if (dota > dotb)
    {
        if (dotc > dota)
            return v[2];
        else
            return v[0];
    }
    else
    {
        if (dotc > dotb)
            return v[2];
        else
            return v[1];
    }
}

/// Transformed support function
Vector3f supTransformed(S)(S shape, Matrix4x4f transformation, Vector3f dir)
{
    Vector3f result;
    result.x = ((dir.x * m.a11) + (dir.y * m.a21)) + (dir.z * m.a31);
    result.y = ((dir.x * m.a12) + (dir.y * m.a22)) + (dir.z * m.a32);
    result.z = ((dir.x * m.a13) + (dir.y * m.a23)) + (dir.z * m.a33);

    result = shape.support(result);

    float x = ((result.x * m.a11) + (result.y * m.a12)) + (result.z * m.a13);
    float y = ((result.x * m.a21) + (result.y * m.a22)) + (result.z * m.a23);
    float z = ((result.x * m.a31) + (result.y * m.a32)) + (result.z * m.a33);

    result.x = m.a14 + x;
    result.y = m.a24 + y;
    result.z = m.a34 + z;
    
    return Vector3f;
}