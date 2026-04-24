using UnityEngine;

public class Pathfinding : MonoBehaviour
{
    public GameObject target;
    [SerializeField] private Rigidbody rb;
    [SerializeField] private float moveSpeed = 5f;

    private void Start()
    {
        // Tự động tìm Rigidbody nếu chưa gán
        if (rb == null)
        {
            rb = GetComponent<Rigidbody>();
        }

        // Tự động tìm Player nếu chưa gán
        if (target == null)
        {
            target = GameObject.FindWithTag("Player");
        }

        if (rb == null) Debug.LogError($"[Pathfinding] {gameObject.name}: Không tìm thấy Rigidbody!");
        if (target == null) Debug.LogError($"[Pathfinding] {gameObject.name}: Không tìm thấy Target!");
        if (moveSpeed <= 0f) Debug.LogWarning($"[Pathfinding] {gameObject.name}: moveSpeed = {moveSpeed}, enemy sẽ không di chuyển!");
    }

    public void Init(GameObject tar)
    {
        target = tar;
    }

    private void FixedUpdate()
    {
        if (target != null && rb != null)
        {
            MoveToTarget();
        }

        if (transform.position.y <= -10f) Destroy(gameObject);
    }

    private void MoveToTarget()
    {
        Vector3 dir = (target.transform.position - transform.position);
        dir.y = 0f; 
        dir = dir.normalized;
        rb.velocity = new Vector3(dir.x * moveSpeed, rb.velocity.y, dir.z * moveSpeed);
    }
}
