using UnityEngine;
using System.Collections;

public class FoundPoint : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
    public NetworkMgr objNw;

    // Update is called once per frame
    void Update () {
	
	}
    public FindPoint objFind;

    void OnSelect()
    {
        Debug.Log("Found Point");
        objFind.placing = false;
        //Send the Data over networking
        SpatialMapping.Instance.DrawVisualMeshes = false;

#if !UNITY_EDITOR
            Debug.Log("Send New Coord :: " + objFind.MoveToPoint.ToString());
            objNw.UWPSend(objFind.MoveToPoint.ToString());
#endif
    }

}
