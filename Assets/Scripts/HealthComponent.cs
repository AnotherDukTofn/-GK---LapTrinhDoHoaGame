using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthComponent : MonoBehaviour
{
    [SerializeField] private float HP;

    private void OnollisionEnter(Collider collision)
    {
        if (collision.CompareTag("Projectile"))
        {
            Bullet dmgSource = collision.GetComponent<Bullet>();
            HurtEffect();
            HP -= dmgSource.damage;
        }
    }

    private void HurtEffect()
    {
        // TODO
    }
}
