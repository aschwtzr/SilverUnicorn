using UnityEngine;
using System.Collections;

public class MoveSphero : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}

    public NetworkMgr objNw;

    void OnForward()
    {
        Debug.Log("Forward");

        if (isSpeech)
        {
            Debug.Log("Forward Speech");
        #if !UNITY_EDITOR
            Debug.Log("UWP Send");
            objNw.UWPSend("1");
        #endif

        }
    }

    void OnRight()
    {
        Debug.Log("Right");
        if (isSpeech)
        {
            Debug.Log("Right Speech");
            #if !UNITY_EDITOR
            Debug.Log("UWP Send");
            objNw.UWPSend("2");
            #endif

        }

    }

    void OnReverse()
    {
        Debug.Log("Reverse");
        if (isSpeech)
        {
            Debug.Log("Reverse Speech");
            #if !UNITY_EDITOR
            Debug.Log("UWP Send");
            objNw.UWPSend("3");
            #endif
        }

    }

    void OnLeft()
    {
        Debug.Log("Left");
        if (isSpeech)
        {
            Debug.Log("Left Speech");
#if !UNITY_EDITOR
            Debug.Log("UWP Send");
            objNw.UWPSend("4");
#endif

        }
    }

    void OnStop()
    {
        Debug.Log("Stop");
        if (isSpeech)
        {
            Debug.Log("Stop");
            #if !UNITY_EDITOR
            Debug.Log("UWP Send");
            objNw.UWPSend("5");
            #endif
        }
    }
    public bool isSpeech = false;


    // Update is called once per frame
    void Update () {
	
	}
}
