using UnityEngine;

public class HealthComponent : MonoBehaviour
{
    [SerializeField] private float HP;
    [SerializeField] private Rigidbody rb;
    [SerializeField] private float knockbackForce = 2f;

    private void OnTriggerEnter(Collider collision)
    {
        if (collision.CompareTag("Projectile"))
        {
            Bullet dmgSource = collision.GetComponent<Bullet>();
            if (dmgSource == null) return;
            HurtEffect(dmgSource.direction);
            HP -= dmgSource.damage;
            Destroy(dmgSource.gameObject);
            if (HP <= 0) Destroy(gameObject);
        }
    }

    private void HurtEffect(Vector3 direction)
    {
        rb.velocity = direction * knockbackForce;
    }
}
