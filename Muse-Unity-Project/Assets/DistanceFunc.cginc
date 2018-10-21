// Adapted from: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

// SIGNED DISTANCE FUNCTIONS //
// These all return the minimum distance from point p to the desired shape's surface, given the other parameters.
// The result is negative if you are inside the shape.  All shapes are centered about the origin, so you may need to
// transform your input point (p) to account for translation or rotation


// Sphere
// s: radius
float sdSphere(float3 p, float s)
{
	return length(p) - s;
}

float2 smin( float2 aa, float2 b, float k )
{
    float2 res = exp( -k*aa ) + exp( -k*b );
    return -log( res )/k;
}

float2 opBlend( float3 p , float k)
{
    float2 d1 = float2(sdSphere(p + float3(0, 1, -5), 1), 0.75);
    float2 d2 = float2(sdSphere(p + float3(3, 1, -5), 1), 0.95);
    return smin( d1, d2, k);
}



// Box
// b: size of box in x/y/z
float sdBox(float3 p, float3 b)
{
	float3 d = abs(p) - b;
	return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float3 opCheapBend( float3 p )
{
    float c = cos(0.1*p.x);
    float s = sin(0.1*p.x);
    float2x2  m = float2x2(c,s,-s,c);
    float3  q = float3(mul(m,p.xy),p.z);
    return q;
}

// Torus
// t.x: diameter
// t.y: thickness
float sdTorus(float3 p, float2 t)
{
	float2 q = float2(length(p.xz) - t.x, p.y);
	return length(q) - t.y;
}

float3 opTwist( float3 p)
{
    float c = cos(1.1*p.y);
    float s = sin(1.1*p.y);
    float2x2 m = float2x2(c,s,-s,c);   // different from glsl implementation because of different matrix ordering
    float3  q = float3(mul(m, p.xz),p.y);
    return q;
}



// Cylinder
// h.x = diameter
// h.y = height
float sdCylinder(float3 p, float2 h)
{
	float2 d = abs(float2(length(p.xz), p.y)) - h;
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdCone(float3 p, float2 c)
{
	// c must be normalized
	float q = length(p.xy);
	return dot(c, float2(q, p.z));
}

// (Infinite) Plane
// n.xyz: normal of the plane (normalized).
// n.w: offset

// BOOLEAN OPERATIONS //
// Apply these operations to multiple "primitive" distance functions to create complex shapes.

// Union
float opU(float d1, float d2)
{
	return min(d1, d2);
}

// Union (with material data)
float2 opU_mat( float2 d1, float2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

// Subtraction
float opS(float d1, float d2)
{
	return max(-d1, d2);
}

// Intersection
float opI(float d1, float d2)
{
	return max(d1, d2);
}

// Union (with extra data)
// d1,d2.x: Distance field result
// d1,d2.y: Extra data (material data for example)
float opU(float2 d1, float2 d2)
{
	return (d1.x < d2.x) ? d1 : d2;
}
