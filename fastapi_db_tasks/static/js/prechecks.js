async function mark_checklist(event, task_type, checklist_key) {
    let isChecked = event.target.checked;
    $.ajax({
        url: '/configs/prechecks',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            "task_type": task_type,
            "checklist_key": checklist_key,
            "completed": isChecked
        })
    }).done(function (response) {
        console.log('Checklist status updated successfully:', response);
        update_prechecks(task_type);
    }).fail(function (error) {
        console.error('Error updating checklist status:', error);
    });
}

async function update_prechecks(task_type) {
    $.ajax({
        url: '/configs/prechecks',
        type: 'GET',
    }).done(function (config) {
        if (!config[task_type]) {
            return;
        }
        let checklists = config[task_type];
        let rows = `<tr id="prechecks_header_${task_type}" class="highlighted_row" type="prechecks_${task_type}">
                    <td colspan="5"><label>Prechecks List<label></td>
        </tr>`;
        Object.keys(checklists).forEach(function (checklist_key) {
            let checklist = checklists[checklist_key];
            let data = checklist["data"].splice(-1)[0] || {};
            rows += `<tr type="prechecks_${task_type}">
                <td>${checklist["title"]}</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" 
                                type="checkbox" role="switch" 
                                id="${checklist_key}_completed" 
                                onclick="mark_checklist(event, '${task_type}', '${checklist_key}');" 
                                ${data["completed"] ? "checked" : ""}
                        >
                        ${data["completed"]}
                    </div>
                </td>
                <td>${data["completed_by"]}</td>
                <td>${data["completed_at"]}</td>
                <td>${data["notes"]}</td>
            </tr>`;
        });

        $(`tr[type="prechecks_${task_type}"]`).remove();
        $(`#${task_type}-tbody-main`).prepend(rows);
    }).fail(function (error) {
        console.error('Error fetching tasks:', error);
    });
}
