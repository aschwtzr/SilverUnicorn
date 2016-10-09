using UnityEngine;
using System.Collections;

public class Reaction : MonoBehaviour
{
    AudioSource audio;
    
    public GameObject MainUI;

    public GameObject MobiH;
    public GameObject SpeechH;
    public GameObject StatusH;
    public GameObject Stats;
    // Use this for initialization
    void Start()
    {
        audio = MainUI.GetComponent<AudioSource>();

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public MoveSphero objMove;
   void OnTriggerEnter(Collider other)
    {
        if (this.gameObject.name.Equals("MobilityIcon"))
        {
            audio.Play();
            MobiH.SetActive(true);
            Debug.Log("This is Mobility");
            
        }
        else if (this.gameObject.name.Equals("SpeechIcon"))
        {
            audio.Play();
            SpeechH.SetActive(true);

            Debug.Log("This is Speech");
            objMove.isSpeech = true;
           
        }
        else if (this.gameObject.name.Equals("StatusIcon"))
        {
            audio.Play();
            StatusH.SetActive(true);
            Stats.SetActive(true);
            Debug.Log("This is Status");
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (this.gameObject.name.Equals("MobilityIcon"))
        {
            audio.Stop();
            MobiH.SetActive(false);
            Debug.Log("This is Mobility");

        }
        else if (this.gameObject.name.Equals("SpeechIcon"))
        {
            audio.Stop();
            SpeechH.SetActive(false);

            Debug.Log("This is Speech");
            objMove.isSpeech = false;

        }
        else if (this.gameObject.name.Equals("StatusIcon"))
        {
            audio.Stop();
            StatusH.SetActive(false);
            Stats.SetActive(false);
            Debug.Log("This is Status");
        }
    }
}
