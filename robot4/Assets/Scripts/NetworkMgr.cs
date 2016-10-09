using UnityEngine;
using System.Collections;
using System;
using System.IO;
using System.Collections.Generic;
#if !UNITY_EDITOR
using Windows.Networking.Sockets;
using Windows.Storage.Streams;
using Windows.Networking;
using Windows.Foundation;
#endif
public class NetworkMgr : MonoBehaviour {

#if !UNITY_EDITOR
    StreamSocket socket2;
    string strhostname = "10.189.2.219";
    string strport = "8651";
    string stringToSend = "";
    public void UWPSend(string p_stringToSend)
    {
    
        stringToSend = p_stringToSend;
        // By default 'HostNameForConnect' is disabled and host name validation is not required. When enabling the
        // text box validating the host name is required since it was received from an untrusted source 
        // (user input). The host name is validated by catching ArgumentExceptions thrown by the HostName 
        // constructor for invalid input.
        // Note that when enabling the text box users may provide names for hosts on the Internet that require the
        // "Internet (Client)" capability.
        HostName hostName;
        try
        {
            hostName = new HostName(strhostname);
        }
        catch (ArgumentException)
        {
            Debug.Log("Hostname Error");
            return;
        }

        socket2 = new StreamSocket();
        try
        {
            // Connections are asynchronous.  
            // !!! NOTE These do not arrive on the main Unity Thread. Most Unity operations will throw in the callback !!!
            IAsyncAction outstandingAction = socket2.ConnectAsync(hostName,strport);
            AsyncActionCompletedHandler aach = new AsyncActionCompletedHandler(NetworkConnectedHandler);
            outstandingAction.Completed = aach;     
        }
        catch (Exception exception)
        {
            Debug.Log("Connect Async exception");
        }    
    }

    int count = 1;
    
    public void NetworkConnectedHandler(IAsyncAction asyncInfo, AsyncStatus status)
    {
        DataWriter networkDataWriter;
        // Status completed is successful.
        if (status == AsyncStatus.Completed)
        {
            // Since we are connected, we can send the data we set aside when establishing the connection.
            using(networkDataWriter = new DataWriter(socket2.OutputStream))
            {
                Debug.Log("Sending " + stringToSend + " to " + strhostname + " at port " + strport);
                //networkDataWriter.WriteUInt32(networkDataWriter.MeasureString(stringToSend));
                //networkDataWriter.WriteString(stringToSend);
                if(stringToSend == "1")
                {
                 networkDataWriter.WriteByte(1);
                }
                else if(stringToSend == "2")
                {
                 networkDataWriter.WriteByte(2);
                }
                else if(stringToSend == "3")
                {
                 networkDataWriter.WriteByte(3);
                }
                else if(stringToSend == "4")
                {
                 networkDataWriter.WriteByte(4);
                }
                else if(stringToSend == "5")
                {
                 networkDataWriter.WriteByte(5);
                }
                
                //networkDataWriter.WriteByte(valuetosend);
                
                // Again, this is an async operation, so we'll set a callback.
                try
                {
                    DataWriterStoreOperation dswo = networkDataWriter.StoreAsync();
                    dswo.Completed = new AsyncOperationCompletedHandler<uint>(DataSentHandler);
                    Debug.Log("NetworkConnectedHandler ::Sending");
                }
                catch (Exception exception)
                {
                    Debug.Log("Store async exception");
                }
            }
        }
        else
        {
            Debug.Log("Failed to establish connection. Error Code: " + asyncInfo.ErrorCode);
            // In the failure case we'll requeue the data and wait before trying again.
            socket2.Dispose();               
        }
    }

        public void DataSentHandler(IAsyncOperation<uint> operation, AsyncStatus status)
        {
            // If we failed, requeue the data and set the deferral time.
            if (status == AsyncStatus.Error)
            {
                Debug.Log("DataSentHandler :: Failed to send");
            }
            else
            {
                Debug.Log("DataSentHandler :: Sent");
            }

            // Always disconnect here since we will reconnect when sending the next mesh.  
            socket2.Dispose();
        }
#endif
}
