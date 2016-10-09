using UnityEngine;
using System.Collections;

public class UISpawnScript : MonoBehaviour {

    //Declare both UI connector and UI icon parent objects
    //Declare starting scales for each
    //Declare end scale for each
    //Decalre necessary bools

    public GameObject connectorElement;
    public GameObject iconParentElement;

    private Transform startingScale;

    public Transform connectorEndScale;
    public Transform iconEndScale;

    public bool isTriggered = false;

    private float scaleSpeed = 5.0f;



	// Use this for initialization
	void Start () {
        //declare scales
        startingScale.localScale = new Vector3(0.0f, 0.0f, 0.0f);

        Vector3 scaleOnStart = startingScale.localScale;

        connectorEndScale.localScale = new Vector3(1.0f, 1.0f, 1.0f);
        iconEndScale.localScale = new Vector3(1.0f, 1.0f, 1.0f);

        // Set scales of each UI element
        connectorElement.transform.localScale = scaleOnStart;
        iconParentElement.transform.localScale = scaleOnStart;
	
	}
	
	// Update is called once per frame
	void Update () {

        // call functions for scale effects 
        // if interaction is detected or collision is made
        if (Input.GetKeyDown(KeyCode.Space))
        {
            isTriggered = true;
        }

        if (isTriggered)
        {
            TriggerEffect();
        }
	
	}

    void TriggerEffect() {
        //scale size by specific axis
        connectorElement.transform.localScale = Vector3.Lerp(connectorElement.transform.localScale, connectorEndScale.localScale, Time.deltaTime * scaleSpeed);

        // Create a delta threshhold
        if (connectorEndScale.localScale == connectorEndScale.localScale * .95f)
        {
            connectorElement.transform.localScale = connectorEndScale.localScale;
        }

        //scale size by specific axis
        connectorElement.transform.localScale = Vector3.Lerp(connectorElement.transform.localScale, iconEndScale.localScale, Time.deltaTime * scaleSpeed);

        // Create a delta threshhold
        if (iconEndScale.localScale == connectorEndScale.localScale * .95f)
        {
            iconEndScale.transform.localScale = iconEndScale.localScale;
        }

    }
}
