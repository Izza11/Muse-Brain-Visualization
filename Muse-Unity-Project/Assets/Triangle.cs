using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Triangle : MonoBehaviour {
	public Vector3 a, b, c;

	//Triangle ();
	public Triangle(Vector3 aa, Vector3 bb, Vector3 cc) 
	{
		this.a = aa;
		this.b = bb;
		this.c = cc;
	}

	public void Set(Vector3 aa, Vector3 bb, Vector3 cc){
		a = aa;
		b = bb;
		c = cc;
	}
		
}
