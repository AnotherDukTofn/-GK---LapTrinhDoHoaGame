using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [SerializeField] private Transform playerBody;
    [SerializeField] private float moveSpeed = 5f; 
    
    private Rigidbody rb;
    private Camera mainCamera;
    private Vector3 moveInput;

    void Awake()
    {
        mainCamera = Camera.main; 
        rb = playerBody.GetComponent<Rigidbody>();

        if (rb != null)
        {
            rb.constraints = RigidbodyConstraints.FreezeRotation; 
        }
        else
        {
            Debug.LogError("Chưa gắn Rigidbody vào Player!");
        }
    }

    void Update()
    {
        moveInput = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical")).normalized;

        RotateTowardsMouse();
    }

    void FixedUpdate()
    {
        MovePlayer();
    }

    private void MovePlayer()
    {
        rb.velocity = new Vector3(moveInput.x * moveSpeed, rb.velocity.y, moveInput.z * moveSpeed);
    }
    
    public Vector3 GetLookDirection()
    {
        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        Plane groundPlane = new Plane(Vector3.up, playerBody.position);
        float rayDistance;

        if (groundPlane.Raycast(ray, out rayDistance))
        {
            Vector3 targetPoint = ray.GetPoint(rayDistance);
            Vector3 direction = (targetPoint - playerBody.position);
            direction.y = 0;
            return direction.normalized;
        }

        return Vector3.zero;
    }

    private void RotateTowardsMouse()
    {
        Vector3 lookDirection = GetLookDirection();

        if (lookDirection != Vector3.zero)
        {
            playerBody.rotation = Quaternion.LookRotation(lookDirection);
        }
    }
}