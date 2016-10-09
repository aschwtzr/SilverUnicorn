using UnityEngine;

public class FindPoint : MonoBehaviour
{
    public bool placing = false;
    public GameObject FindFocus;

    // Called by GazeGestureManager when the user performs a Select gesture
    void OnSelect()
    {
        // On each Select gesture, toggle whether the user is in placing mode.
        placing = !placing;

        // If the user is in placing mode, display the spatial mapping mesh.
        if (placing)
        {
            Debug.Log("Found Point On Mesh");

            SpatialMapping.Instance.DrawVisualMeshes = true;
        }
        // If the user is not in placing mode, hide the spatial mapping mesh.
        else
        {
            Debug.Log("Found Point Off Mesh");
            SpatialMapping.Instance.DrawVisualMeshes = false;


        }
    }
    public Vector3  MoveToPoint;
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
                FindFocus.transform.position = hitInfo.point;
                // Rotate this object's parent object to face the user.
                Quaternion toQuat = Camera.main.transform.localRotation;
                toQuat.x = 0;
                toQuat.z = 0;
                FindFocus.transform.rotation = toQuat;
                MoveToPoint = hitInfo.point;
            }
        }
    }
}
