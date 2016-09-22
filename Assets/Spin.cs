using UnityEngine;
using System.Collections;

public class Spin : MonoBehaviour {

    [SerializeField]
    private Vector3 spin;
	
	// Update is called once per frame
	void Update () {
        transform.Rotate(spin);
	}
}
