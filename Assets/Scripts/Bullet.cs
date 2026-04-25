using System.Numerics;
using UnityEngine;
using Vector3 = UnityEngine.Vector3;

public class Bullet : MonoBehaviour
{
    [SerializeField] private Rigidbody rb;
    public Vector3 direction;
    [SerializeField] private float speed;
    [SerializeField] private float distance;
    [SerializeField] private Vector3 origin;
    public float damage;

    public void Init(Vector3 dir)
    {
        direction = dir;
        origin = transform.position;
        rb.velocity = speed * direction.normalized;
    }

    private void Update()
    {
        if (Vector3.Distance(transform.position, origin) >= distance) 
            Destroy(this.gameObject);     
    }
}
