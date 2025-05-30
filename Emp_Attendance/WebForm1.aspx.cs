using Microsoft.Reporting.WebForms;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Web.UI.WebControls;

namespace EmployeeAttendanceModule
{
    public partial class EmployeeAttendance : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
                
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (DateTime.TryParse(txtDate.Text, out DateTime date) &&
                TimeSpan.TryParse(txtTimeIn.Text, out TimeSpan timeIn) &&
                TimeSpan.TryParse(txtTimeOut.Text, out TimeSpan timeOut))
            {
                if (timeOut <= timeIn)
                {
                    lblMessage.Text = "Time Out must be after Time In.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query;
                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = conn;

                    if (string.IsNullOrEmpty(hfAttendanceID.Value)) // Insert new record
                    {
                        query = "INSERT INTO EmployeeAttendance (EmployeeID, EmployeeName, AttendanceDate, TimeIn, TimeOut, Remarks) " +
                                "VALUES (@EmployeeID, @EmployeeName, @AttendanceDate, @TimeIn, @TimeOut, @Remarks)";
                        cmd.CommandText = query;
                    }
                    else // Update existing record
                    {
                        query = "UPDATE EmployeeAttendance SET EmployeeID=@EmployeeID, EmployeeName=@EmployeeName, AttendanceDate=@AttendanceDate, " +
                                "TimeIn=@TimeIn, TimeOut=@TimeOut, Remarks=@Remarks WHERE AttendanceID=@AttendanceID";
                        cmd.CommandText = query;
                        cmd.Parameters.AddWithValue("@AttendanceID", Convert.ToInt32(hfAttendanceID.Value));
                    }

                    cmd.Parameters.AddWithValue("@EmployeeID", txtEmployeeID.Text);
                    cmd.Parameters.AddWithValue("@EmployeeName", txtEmployeeName.Text);
                    cmd.Parameters.AddWithValue("@AttendanceDate", date);
                    cmd.Parameters.AddWithValue("@TimeIn", timeIn);
                    cmd.Parameters.AddWithValue("@TimeOut", timeOut);
                    cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                    conn.Close();

                    lblMessage.Text = string.IsNullOrEmpty(hfAttendanceID.Value) ? "Attendance record saved successfully." : "Attendance record updated successfully.";
                    lblMessage.ForeColor = System.Drawing.Color.Green;

                    ClearForm();
                    BindGrid();
                }
            }
            else
            {
                lblMessage.Text = "Please enter valid date and time values.";
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
            lblMessage.Text = "";
        }

        private void ClearForm()
        {
            hfAttendanceID.Value = "";
            txtEmployeeID.Text = "";
            txtEmployeeName.Text = "";
            txtDate.Text = "";
            txtTimeIn.Text = "";
            txtTimeOut.Text = "";
            txtRemarks.Text = "";
        }

        private void BindGrid()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT * FROM EmployeeAttendance ORDER BY AttendanceDate DESC";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                GridView1.DataSource = dt;
                GridView1.DataBind();
            }
        }

        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "SelectRecord")
            {
                GridViewRow row = GridView1.Rows[rowIndex];

                hfAttendanceID.Value = GridView1.DataKeys[rowIndex].Value.ToString();
                txtEmployeeID.Text = row.Cells[0].Text;
                txtEmployeeName.Text = row.Cells[1].Text;
                txtDate.Text = Convert.ToDateTime(row.Cells[2].Text).ToString("yyyy-MM-dd");
                txtTimeIn.Text = row.Cells[3].Text;
                txtTimeOut.Text = row.Cells[4].Text;
                txtRemarks.Text = row.Cells[5].Text;

                lblMessage.Text = "Record loaded for editing.";
                lblMessage.ForeColor = System.Drawing.Color.Blue;
            }
            else if (e.CommandName == "DeleteRecord")
            {
                string attendanceID = GridView1.DataKeys[rowIndex].Value.ToString();

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand("DELETE FROM EmployeeAttendance WHERE AttendanceID = @AttendanceID", conn);
                    cmd.Parameters.AddWithValue("@AttendanceID", attendanceID);
                    cmd.ExecuteNonQuery();
                }

                lblMessage.Text = "Record deleted successfully.";
                lblMessage.ForeColor = System.Drawing.Color.Green;

                BindGrid();
                ClearForm();
            }
        }
        protected void btnGenerateReport_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT * FROM EmployeeAttendance ORDER BY AttendanceDate DESC", conn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ReportViewer1.LocalReport.DataSources.Clear();
                ReportDataSource ds = new ReportDataSource("DataSet1", dt); // Match this with your RDLC DataSet name
                ReportViewer1.LocalReport.ReportPath = Server.MapPath("~/Report1.rdlc");
                ReportViewer1.LocalReport.DataSources.Add(ds);
                ReportViewer1.LocalReport.Refresh();
            }
        }
       
            

    }
}