using UnityEngine;

public class RotatorAroundY : MonoBehaviour
{
    #region Field

    /// <summary>
    /// 回転軸の位置。
    /// </summary>
    public Vector3 rotateAxisPosition;

    /// <summary>
    /// 回転する速度(角度)。
    /// </summary>
    public float rotateSpeedDegree = 1;

    #endregion Field

    protected virtual void Update ()
    {
        base.transform.RotateAround(this.rotateAxisPosition, 
                                    Vector3.up,
                                    this.rotateSpeedDegree);
    }
}