using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class CameraMask : MonoBehaviour {

    //The shader effect
    [SerializeField]
    private Shader effect;

    //the size of the cut
    [SerializeField][Range(0.0001f, 50)]
    private float size;

    //smooth of the cut
    [SerializeField][Range(0.0001f, 10)]
    private float smooth;

    [SerializeField][Range(0.0001f, 50)]
    private float carveDepth;

    [SerializeField][Range(0.0001f, 50)]
    private float carveSmooth;

    [SerializeField] [Range(0, 1)]
    private float maxAlphaValue;

    [SerializeField]
    private Camera baseCamera;

    //generated material
    private Material mat;

    /// <summary>
    /// Create a render texture on the fly copying the main camera's aspect, and attach it to another given camera
    /// </summary>
    /// <param name="camera">the camera that will start to record its info inside the render texture</param>
    /// <param name="mainCamera">the main camera</param>
    /// <returns>the render texture</returns>
    RenderTexture GetBaseRenderTexture(Camera camera, Camera mainCamera)
    {
        //create a render texture object, using the main camera aspects
        RenderTexture renderTex = new RenderTexture(mainCamera.pixelWidth, mainCamera.pixelHeight, 16);

        //set the new camera to render on the tecture
        camera.SetTargetBuffers(renderTex.colorBuffer, renderTex.depthBuffer);

        //return the render texture
        return renderTex;
    }

    void SetupRenderEffectMaterial(RenderTexture baseTex)
    {
        //build the effect material
        mat = new Material(effect);

        //sent the render texture inside the material
        mat.SetTexture("_BaseTex", baseTex);

        //set the effect's size
        mat.SetFloat("_Size", size);

        //set the material's smooth
        mat.SetFloat("_Smooth", smooth);

        mat.SetFloat("_CarveDepth", carveDepth);

        mat.SetFloat("_CarveSmooth", carveSmooth);

        mat.SetFloat("_MaxAlphaValue", maxAlphaValue);
    }


    void Start () {
        //get the camera component
        Camera mainCamera = GetComponent<Camera>();

        //set the camera to print its depth texture
        mainCamera.depthTextureMode = DepthTextureMode.Depth;

        //setup the effect's material
        SetupRenderEffectMaterial(GetBaseRenderTexture(baseCamera, mainCamera));
    }
	
    void OnRenderImage(RenderTexture baseTex, RenderTexture finalTex)
    {
        //blit the camera using the effect
        Graphics.Blit(baseTex, finalTex, mat);
    }
}
