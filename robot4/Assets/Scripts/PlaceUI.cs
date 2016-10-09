using UnityEngine;
using System.Collections;

public class PlaceUI : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
    
    public TapToPlaceParent objTapToPlace; //Change to vuforia thing
    public GameObject RobotUI;
    void OnSelect()
    {
        Debug.Log("On Select PlaceUI");
        objTapToPlace.placing = false;
        SpatialMapping.Instance.DrawVisualMeshes = false;
        RobotUI.transform.position = this.transform.position;
        RobotUI.transform.rotation = this.transform.rotation;
        RobotUI.SetActive(true);
}

}
