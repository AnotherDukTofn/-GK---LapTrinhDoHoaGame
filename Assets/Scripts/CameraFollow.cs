using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    [Header("Target & Setup")]
    [SerializeField] private Transform target;
    [SerializeField] private Rigidbody targetRb; // Cần Rigidbody của nhân vật để kiểm tra vận tốc
    [SerializeField] private Vector3 offset = new Vector3(0f, 0f, -5f);
    [SerializeField] private float smoothTime = 0.2f;

    [Header("Deadzone & Timer")]
    [SerializeField] private Vector2 deadzoneSize = new Vector2(2f, 2f);
    [SerializeField] private float idleWaitTime = 1f; // Thời gian chờ để về tâm (1 giây)

    private float fixedY;
    private Vector3 currentFollowPosition;
    private Vector3 currentVelocity = Vector3.zero;
    
    private float idleTimer = 0f;
    private bool isFollowing = false;

    void Awake()
    {
        fixedY = transform.position.y;
        if (target != null) currentFollowPosition = target.position;
    }

    void LateUpdate()
    {
        if (target == null) return;

        Vector3 targetPos = target.position;

        float deltaX = targetPos.x - currentFollowPosition.x;
        float deltaZ = targetPos.z - currentFollowPosition.z;

        if (Mathf.Abs(deltaX) > deadzoneSize.x || Mathf.Abs(deltaZ) > deadzoneSize.y)
        {
            isFollowing = true;
            idleTimer = 0f; // Reset thời gian chờ vì đang di chuyển/ngoài vùng
            currentFollowPosition = targetPos;
        }
        else
        {
            // 3. LOGIC KHI ĐANG Ở TRONG DEADZONE
            // Kiểm tra xem nhân vật có thực sự đứng yên không (vận tốc gần bằng 0)
            bool isMoving = targetRb != null ? targetRb.velocity.sqrMagnitude > 0.01f : false;

            if (!isMoving)
            {
                idleTimer += Time.deltaTime;
                if (idleTimer >= idleWaitTime)
                {
                    // Sau 1 giây đứng yên, ép Camera về tâm nhân vật
                    currentFollowPosition = targetPos;
                    isFollowing = true;
                }
            }
            else
            {
                idleTimer = 0f;
                // Nếu đang di chuyển TRONG deadzone, isFollowing vẫn giữ trạng thái cũ 
                // hoặc tắt đi nếu đã về sát tâm để cam không bị trôi
                if (Vector3.Distance(transform.position - offset, targetPos) < 0.1f)
                {
                    isFollowing = false;
                }
            }
        }

        // 4. THỰC THI DI CHUYỂN CAMERA
        if (isFollowing)
        {
            Vector3 desiredPosition = currentFollowPosition + offset;
            desiredPosition.y = fixedY;

            transform.position = Vector3.SmoothDamp(
                transform.position, 
                desiredPosition, 
                ref currentVelocity, 
                smoothTime
            );

            // Tự động dừng bám đuổi khi đã tới rất gần mục tiêu để tránh tốn hiệu năng
            if (currentVelocity.sqrMagnitude < 0.001f && idleTimer > idleWaitTime)
            {
                isFollowing = false;
            }
        }
    }

    private void OnDrawGizmos()
    {
        if (target == null) return;
        Gizmos.color = Color.red;
        Vector3 center = currentFollowPosition;
        center.y = target.position.y;
        Gizmos.DrawWireCube(center, new Vector3(deadzoneSize.x * 2, 0.1f, deadzoneSize.y * 2));
    }
}