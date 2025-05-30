<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeAttendance.aspx.cs" Inherits="EmployeeAttendanceModule.EmployeeAttendance" %>

<%@ Register assembly="Microsoft.ReportViewer.WebForms" namespace="Microsoft.Reporting.WebForms" tagprefix="rsweb" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Employee Attendance</title>
    <style>
    body {
        font-family: 'Segoe UI', sans-serif;
        margin: 0;
        padding: 0;
        background-color: #121212;
        color: #e0e0e0;
        transition: background-color 0.3s, color 0.3s;
    }

    .container {
        max-width: 700px;
        margin: 40px auto;
        background: #1e1e1e;
        padding: 25px;
        box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
        border-radius: 10px;
        transition: background-color 0.3s, color 0.3s;
    }

    h2 {
        text-align: center;
        color: #ffffff;
        margin-bottom: 25px;
    }

    label,
    .form-label {
        font-weight: bold;
        margin-top: 10px;
        display: block;
        color: #e0e0e0;
    }

    input[type="text"],
    input[type="date"],
    input[type="time"],
    textarea {
        width: 100%;
        padding: 10px;
        margin: 4px 0 10px;
        border: 1px solid #444;
        border-radius: 5px;
        box-sizing: border-box;
        background-color: #2a2a2a;
        color: #ffffff;
    }

    input[type="text"]::placeholder,
    input[type="date"]::placeholder,
    input[type="time"]::placeholder,
    textarea::placeholder {
        color: #aaaaaa;
    }

    .form-buttons {
        text-align: center;
        margin-top: 20px;
    }

    .form-buttons input[type="submit"],
    .form-buttons input[type="button"],
    .form-buttons button {
        background-color: #007bff;
        color: white;
        border: none;
        padding: 10px 18px;
        margin: 5px;
        border-radius: 5px;
        cursor: pointer;
        transition: background-color 0.2s;
    }

    .form-buttons input:hover,
    .form-buttons button:hover {
        background-color: #0056b3;
    }

    .error-message {
        color: #ff6b6b;
        font-size: 0.9em;
    }

    .success-message {
        color: #4caf50;
        text-align: center;
        margin-top: 10px;
    }

    .gridview {
        margin-top: 30px;
    }

    .gridview table {
        width: 100%;
        border-collapse: collapse;
        background: #1e1e1e;
        color: #e0e0e0;
    }

    .gridview th,
    .gridview td {
        padding: 10px;
        border: 1px solid #444;
        text-align: center;
    }

    .gridview th {
        background-color: #333;
        color: #ffffff;
    }

    .gridview tr:nth-child(even) {
        background-color: #2a2a2a;
    }

    .gridview tr:hover {
        background-color: #3c3c3c;
    }

    .toggle-switch {
        display: flex;
        justify-content: flex-end;
        margin: 10px 30px;
    }

    .toggle-switch label {
        display: flex;
        align-items: center;
        gap: 10px;
        font-weight: bold;
        color: #e0e0e0;
    }

    .toggle-switch input[type="checkbox"] {
        transform: scale(1.5);
        cursor: pointer;
    }
</style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2>Employee Attendance Form</h2>

            <asp:HiddenField ID="hfAttendanceID" runat="server" />
         

            <asp:Label Text="Employee ID:" CssClass="form-label" runat="server" />
            <asp:TextBox ID="txtEmployeeID" runat="server" />
            <asp:RequiredFieldValidator ID="rfvEmployeeID" runat="server"
                ControlToValidate="txtEmployeeID" ErrorMessage="Required" ForeColor="Red" Display="Dynamic" CssClass="error-message" />

            <asp:Label Text="Employee Name:" CssClass="form-label" runat="server" />
            <asp:TextBox ID="txtEmployeeName" runat="server" />
            <asp:RequiredFieldValidator ID="rfvEmployeeName" runat="server"
                ControlToValidate="txtEmployeeName" ErrorMessage="Required" ForeColor="Red" Display="Dynamic" CssClass="error-message" />

            <asp:Label Text="Date:" CssClass="form-label" runat="server" />
            <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
            <asp:RequiredFieldValidator ID="rfvDate" runat="server"
                ControlToValidate="txtDate" ErrorMessage="Required" ForeColor="Red" Display="Dynamic" CssClass="error-message" />

            <asp:Label Text="Time In:" CssClass="form-label" runat="server" />
            <asp:TextBox ID="txtTimeIn" runat="server" TextMode="Time" />
            <asp:RequiredFieldValidator ID="rfvTimeIn" runat="server"
                ControlToValidate="txtTimeIn" ErrorMessage="Required" ForeColor="Red" Display="Dynamic" CssClass="error-message" />

            <asp:Label Text="Time Out:" CssClass="form-label" runat="server" />
            <asp:TextBox ID="txtTimeOut" runat="server" TextMode="Time" />
            <asp:RequiredFieldValidator ID="rfvTimeOut" runat="server"
                ControlToValidate="txtTimeOut" ErrorMessage="Required" ForeColor="Red" Display="Dynamic" CssClass="error-message" />

            <asp:Label Text="Remarks:" CssClass="form-label" runat="server" />
            <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="3" />

            <div class="form-buttons">
                <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" />
                <asp:Button ID="btnGenerateReport" runat="server" Text="Generate Report" OnClick="btnGenerateReport_Click" />
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="success-message" />

            <div class="gridview">
                <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
                    DataKeyNames="AttendanceID"
                    OnRowCommand="GridView1_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="EmployeeID" HeaderText="Employee ID" />
                        <asp:BoundField DataField="EmployeeName" HeaderText="Name" />
                        <asp:BoundField DataField="AttendanceDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
                        <asp:BoundField DataField="TimeIn" HeaderText="Time In" />
                        <asp:BoundField DataField="TimeOut" HeaderText="Time Out" />
                        <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                        <asp:ButtonField CommandName="SelectRecord" Text="Select" ButtonType="Button" />
                        <asp:ButtonField CommandName="DeleteRecord" Text="Delete" ButtonType="Button" />
                    </Columns>
                </asp:GridView>
               
            </div>
           
        </div>
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <!-- Your ReportViewer control here -->
        <rsweb:ReportViewer ID="ReportViewer1" runat="server" Width="100%" Height="600px">
        </rsweb:ReportViewer>
    </form>
   
</body>
</html>
