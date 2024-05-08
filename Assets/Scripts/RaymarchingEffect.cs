using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(RaymarchingRenderer), PostProcessEvent.AfterStack, "Custom/Raymarching")]
public sealed class Raymarching : PostProcessEffectSettings
{
    // [Range(0f, 1f), Tooltip("Raymarching effect intensity.")]
    // public FloatParameter blend = new FloatParameter { value = 0.5f };
}

public sealed class RaymarchingRenderer : PostProcessEffectRenderer<Raymarching>
{
    public override void Render(PostProcessRenderContext context)
    {
        var camera = context.camera;
        var v = camera.worldToCameraMatrix;
        var vp = camera.projectionMatrix * camera.worldToCameraMatrix;

        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Raymarching"));
        // sheet.properties.SetFloat("_Blend", settings.blend);
        sheet.properties.SetVector("_CameraPosition", camera.transform.position);
        sheet.properties.SetMatrix("_CameraFrustum", FrustumCorners(camera));
        sheet.properties.SetMatrix("_CameraWorldSpace", camera.cameraToWorldMatrix);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }

    private Matrix4x4 FrustumCorners(Camera cam)
    {
        Transform camtr = cam.transform;

        Vector3[] frustumCorners = new Vector3[4];
        cam.CalculateFrustumCorners(new Rect(0, 0, 1, 1),
        cam.farClipPlane, cam.stereoActiveEye, frustumCorners);

        Vector3 bottomLeft = camtr.TransformVector(frustumCorners[1]);
        Vector3 topLeft = camtr.TransformVector(frustumCorners[0]);
        Vector3 bottomRight = camtr.TransformVector(frustumCorners[2]);

        Matrix4x4 frustumVectorsArray = Matrix4x4.identity;
        frustumVectorsArray.SetRow(0, bottomLeft);
        frustumVectorsArray.SetRow(1, bottomLeft + (bottomRight - bottomLeft) * 2);
        frustumVectorsArray.SetRow(2, bottomLeft + (topLeft - bottomLeft) * 2);

        return frustumVectorsArray;
    }
}
