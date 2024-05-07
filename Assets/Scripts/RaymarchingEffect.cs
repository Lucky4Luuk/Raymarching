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
        var vp = camera.projectionMatrix * camera.worldToCameraMatrix;

        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Raymarching"));
        // sheet.properties.SetFloat("_Blend", settings.blend);
        sheet.properties.SetVector("_CameraPosition", camera.transform.position);
        sheet.properties.SetMatrix("_ViewProjectInverse", vp.inverse);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
