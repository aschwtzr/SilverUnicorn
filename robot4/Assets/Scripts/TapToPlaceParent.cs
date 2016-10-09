using UnityEngine;

public class TapToPlaceParent : MonoBehaviour
{
    public bool placing = false;

    // Called by GazeGestureManager when the user performs a Select gesture
    void OnSelect()
    {
        // On each Select gesture, toggle whether the user is in placing mode.
        placing = !placing;

        // If the user is in placing mode, display the spatial mapping mesh.
        if (placing)
        {
            Debug.Log("UI Mesh on");

            SpatialMapping.Instance.DrawVisualMeshes = true;
        }
        // If the user is not in placing mode, hide the spatial mapping mesh.
        else
        {
            Debug.Log("!placing");
            SpatialMapping.Instance.DrawVisualMeshes = false;
            DefaultUIElem.transform.position = hitpos;
            DefaultUIElem.transform.rotation = hitrot;
        }
    }
    public GameObject DefaultUI;
    public GameObject DefaultUIElem;
    Vector3 hitpos;
    Quaternion hitrot;
    // Update is called once per frame
    void Update()
    {
        // If the user is in placing mode,
        // update the placement to match the user's gaze.

        if (placing)
        {
            // Do a raycast into the world that will only hit the Spatial Mapping mesh.
            var headPosition = Camera.main.transform.position;
            var gazeDirection = Camera.main.transform.forward;

            RaycastHit hitInfo;
            if (Physics.Raycast(headPosition, gazeDirection, out hitInfo,
                30.0f, SpatialMapping.PhysicsRaycastMask))
            {
                // Move this object's parent object to
                // where the raycast hit the Spatial Mapping mesh.
                DefaultUI.transform.position = hitInfo.point;
                hitpos = DefaultUI.transform.position;
                // Rotate this object's parent object to face the user.
                Quaternion toQuat = Camera.main.transform.localRotation;
                toQuat.x = 0;
                toQuat.z = 0;
                DefaultUI.transform.rotation = toQuat;
                hitrot = DefaultUI.transform.rotation;
            }
        }
    }
}
