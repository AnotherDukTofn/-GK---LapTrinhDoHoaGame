using UnityEngine;

public class EnemySpawner : MonoBehaviour
{
    [SerializeField] private Pathfinding enemy;
    [SerializeField] private float cooldown = 2f;
    [SerializeField] private Vector2 spawnRangeX = new Vector2(0f, 50f);
    [SerializeField] private Vector2 spawnRangeZ = new Vector2(0f, 50f);
    [SerializeField] private GameObject player;

    private float timer = 0f;

    private void Update()
    {
        timer += Time.deltaTime;
        if (timer >= cooldown)
        {
            SpawnEnemy();
            timer = 0f; 
        }
    }

    private void SpawnEnemy()
    {
        float x = UnityEngine.Random.Range(spawnRangeX.x, spawnRangeX.y);
        float z = UnityEngine.Random.Range(spawnRangeZ.x, spawnRangeZ.y);
        Pathfinding clone = Instantiate(enemy, new Vector3(x, 5f, z), Quaternion.identity); 
        clone.Init(player);
    }
}