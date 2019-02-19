
module dlib.image.convexhull;

import std.stdio;
import std.algorithm;
import std.algorithm.searching;
import std.algorithm.mutation;
import std.math;

import dlib.container;
import dlib.image.measure;

// https://www.geeksforgeeks.org/convex-hull-set-1-jarviss-algorithm-or-wrapping/
// Jarvis’s Algorithm or Wrapping
//
// To find orientation of ordered triplet (p, q, r). 
// The function returns following values 
// 0 --> p, q and r are colinear 
// 1 --> Clockwise 
// 2 --> Counterclockwise 
int orientation(Point p, Point q, Point r) 
{ 
    int val = (q.y - p.y) * (r.x - q.x) - 
              (q.x - p.x) * (r.y - q.y); 
  
    if (val == 0) return 0;  // colinear 
    return (val > 0)? 1: 2; // clock or counterclock wise 
} 
 
XYList convHull(XYList points) 
{ 
    int n = cast(int)points.xs.length;
    
    assert (n >= 3); // There must be at least 3 points 
    
    DynamicArray!Point hull; 
    
    int l = 0; 
    for (int i = 1; i < n; i++) 
        if (points.xs[i] < points.xs[l]) 
            l = i;
    
    int p = l;
    int q;
    do
    { 
        hull.append(Point(points.xs[p], points.ys[p])); 
        
        q = (p+1)%n; 
        for (int i = 0; i < n; i++) 
        { 
        
           if (orientation(Point(points.xs[p], points.ys[p]), 
                           Point(points.xs[i], points.ys[i]),
                           Point(points.xs[q], points.ys[q])) == 2)
               q = i; 
        } 
        p = q; 
  
    } while (p != l);
    
    XYList xys;
    foreach(i; 0..hull.length){
        xys.xs ~= hull[i].x;
        xys.ys ~= hull[i].y;
    }
    return xys; 
}