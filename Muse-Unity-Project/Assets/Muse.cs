using UnityEngine;
using System.Collections;
using System;
using SharpOSC;

/* This class is never instantiated, so everything is a static function */
public class Muse : MonoBehaviour {

	public UDPListener listener;

	private static float[] acc_recent = { 0f, 0f, 0f , 0f};			// Most recently recorded position data

	public float[] eeg_data = {0f, 0f, 0f, 0f}; 

	void Start() 
	{
		// Callback function for received OSC messages.
		HandleOscPacket callback = delegate(OscPacket packet)
		{
			var messageReceived = (OscMessage)packet;
			var addr = messageReceived.Address;

			if(addr == "Person0/notch_filtered_eeg") {

				/*
				Debug.Log("eeg START : ");
				foreach(var arg in messageReceived.Arguments) {
					Debug.Log(float.Parse(arg.ToString()) + " ");

				}
				*/


				eeg_data[0] = float.Parse( messageReceived.Arguments[0].ToString() );
				eeg_data[1] = float.Parse( messageReceived.Arguments[1].ToString() );
				eeg_data[2] = float.Parse( messageReceived.Arguments[2].ToString() );
				eeg_data[3] = float.Parse( messageReceived.Arguments[3].ToString() );

				//CallbackAcc(eeg_data);
				

			}


		};

		// Create an OSC server.
		listener = new UDPListener(5005, callback);
		Console.WriteLine("Press enter to stop");
		Console.ReadLine();

	}

	void Update() 
	{
		
	}

	void OnApplicationQuit() 
	{
		listener.Close();
	}


	private static void CallbackAcc(float[] eeg_data)
	{
		for (int i = 0; i < 4; i++) {
			acc_recent[i] = eeg_data[i];
			Debug.Log (acc_recent[i]);
		}

	}


}	