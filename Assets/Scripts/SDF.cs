using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDF : MonoBehaviour
{
    public SDFType kind;
    public SDFMaterial material;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
}

public enum SDFType {
    Sphere = 0,
}
