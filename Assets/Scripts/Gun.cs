using System;
using UnityEngine;

public class Gun : MonoBehaviour
{
    [SerializeField] private Bullet bullet;
    [SerializeField] private PlayerController player;
    public void Shoot()
    {
        Bullet instance = Instantiate(bullet, transform.position, transform.rotation);
        instance.Init(player.GetLookDirection());
    }

    private void Update()
    {
        if (Input.GetMouseButtonDown(0)) 
        {
            Shoot();
        }
    }
}
