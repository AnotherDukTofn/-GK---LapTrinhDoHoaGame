using System;
using UnityEngine;

public class Gun : MonoBehaviour
{
    [SerializeField] private Bullet bullet;
    [SerializeField] private PlayerController player;
    [SerializeField] private float fireRate = 0.2f;
    private float fireCooldown = 0f;

    public void Shoot()
    {
        Bullet instance = Instantiate(bullet, transform.position, transform.rotation);
        instance.Init(player.GetLookDirection());
        fireCooldown = fireRate;
    }

    private void Update()
    {
        fireCooldown -= Time.deltaTime;
        if (Input.GetMouseButtonDown(0) && fireCooldown <= 0f) 
        {
            Shoot();
        }
    }
}
