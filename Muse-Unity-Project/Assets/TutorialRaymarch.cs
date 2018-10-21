using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu("Effects/Raymarch (Generic)")]
public class TutorialRaymarch : MonoBehaviour {

	[SerializeField]
	private Shader _EffectShader;
	private Material _EffectMaterial;
	public Transform SunLight;
	float move = 1.0f;

	[SerializeField]
	private Texture2D _ColorRamp;

	public Material EffectMaterial
	{
		get
		{
			if (!_EffectMaterial && _EffectShader)
			{
				_EffectMaterial = new Material(_EffectShader);
				_EffectMaterial.hideFlags = HideFlags.HideAndDontSave;
			}

			return _EffectMaterial;
		}
	}
	void Start(){

	}

	void Update(){
	
		move += 0.01f;
		for (int i = 0; i < 4; i++) {
			Debug.Log (gameObject.GetComponent<Muse>().eeg_data[i]);
		}
	
	}


	public Camera CurrentCamera
	{
		get
		{
			if (!_CurrentCamera)
				_CurrentCamera = GetComponent<Camera>();
			return _CurrentCamera;
		}
	}
	private Camera _CurrentCamera;


	[ImageEffectOpaque]
	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (!EffectMaterial)
		{
			Graphics.Blit(source, destination); // do nothing
			return;
		}

		Matrix4x4 MatTorus = Matrix4x4.TRS(
			Vector3.right * Mathf.Sin(Time.time) * 5, 
			Quaternion.identity,
			Vector3.one);
		MatTorus *= Matrix4x4.TRS(
			Vector3.zero, 
			Quaternion.Euler(new Vector3(0, 0, (Time.time * 200) % 360)), 
			Vector3.one);
		
		// pass frustum rays to shader
		EffectMaterial.SetVector("_CameraWS", CurrentCamera.transform.position);
		EffectMaterial.SetMatrix("_CameraInvViewMatrix", CurrentCamera.cameraToWorldMatrix);
		EffectMaterial.SetMatrix("_FrustumCornersES", GetFrustumCorners(CurrentCamera));
		EffectMaterial.SetVector("_LightDir", SunLight ? SunLight.forward : Vector3.down);
		EffectMaterial.SetFloat("move", move);
		EffectMaterial.SetFloat("eegData", gameObject.GetComponent<Muse>().eeg_data[0]);
		EffectMaterial.SetFloat("time", Time.time);
		EffectMaterial.SetTexture("_ColorRamp", _ColorRamp);

		CustomGraphicsBlit(source, destination, EffectMaterial, 0);
	}



	private Matrix4x4 GetFrustumCorners(Camera cam)
	{
		float camFov = cam.fieldOfView;
		float camAspect = cam.aspect;

		Matrix4x4 frustumCorners = Matrix4x4.identity;

		float fovWHalf = camFov * 0.5f;

		float tan_fov = Mathf.Tan(fovWHalf * Mathf.Deg2Rad);

		Vector3 toRight = Vector3.right * tan_fov * camAspect;
		Vector3 toTop = Vector3.up * tan_fov;

		Vector3 topLeft = (-Vector3.forward - toRight + toTop);
		Vector3 topRight = (-Vector3.forward + toRight + toTop);
		Vector3 bottomRight = (-Vector3.forward + toRight - toTop);
		Vector3 bottomLeft = (-Vector3.forward - toRight - toTop);

		frustumCorners.SetRow(0, topLeft);
		frustumCorners.SetRow(1, topRight);
		frustumCorners.SetRow(2, bottomRight);
		frustumCorners.SetRow(3, bottomLeft);

		return frustumCorners;
	}


	static void CustomGraphicsBlit(RenderTexture source, RenderTexture dest, Material fxMaterial, int passNr)
	{
		RenderTexture.active = dest;

		fxMaterial.SetTexture("_MainTex", source);

		GL.PushMatrix();
		GL.LoadOrtho(); // Note: z value of vertices don't make a difference because we are using ortho projection

		fxMaterial.SetPass(passNr);

		GL.Begin(GL.QUADS);

		// Here, GL.MultitexCoord2(0, x, y) assigns the value (x, y) to the TEXCOORD0 slot in the shader.
		// GL.Vertex3(x,y,z) queues up a vertex at position (x, y, z) to be drawn.  Note that we are storing
		// our own custom frustum information in the z coordinate.
		GL.MultiTexCoord2(0, 0.0f, 0.0f);
		GL.Vertex3(0.0f, 0.0f, 3.0f); // BL

		GL.MultiTexCoord2(0, 1.0f, 0.0f);
		GL.Vertex3(1.0f, 0.0f, 2.0f); // BR

		GL.MultiTexCoord2(0, 1.0f, 1.0f);
		GL.Vertex3(1.0f, 1.0f, 1.0f); // TR

		GL.MultiTexCoord2(0, 0.0f, 1.0f);
		GL.Vertex3(0.0f, 1.0f, 0.0f); // TL

		GL.End();
		GL.PopMatrix();
	}



}