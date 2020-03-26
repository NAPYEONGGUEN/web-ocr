<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>web-ocr</title>
    <!--bootstrap-->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.11.0/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/js/bootstrap.min.js"></script>




    <style>
        html {
            height: 100%;
            overflow: hidden;
        }


        body {
            margin: 0;
            padding: 0;
            perspective: 1px;
            transform-style: preserve-3d;
            height: 100%;
            overflow-x: hidden;
            overflow-y: auto;
            font-family: "Luna";
            background: #454c55;

        }

        .content {

            background: white;
            padding: 30px;
            border-radius: 5px;

        }

        .hide {
            display: none;
        }

        .thubnail {
            width: 180px;
            height: auto;
        }

        #selectedImgs {
            display: none;
        }

        #myBar {
            width: 0%;
            height: 40px;
            background-color: #277daa;
            text-align: center;
            /* To center it horizontally (if you want) */
            line-height: 30px;
            /* To center it vertically */
            color: white;
        }
    </style>


</head>

<body>
    <div class="container" style="margin-top: 100px;">
        <div class="row">
            <div class="col-lg">
                <div class="content">
                    <div class="row">
                        <div class="col">
                            <h2>전표 자동인식</h2>
                        </div>
                    </div>
                    <hr />
                    <div class="row">
                        <div class="col">
                            <form action="" id="main">
                                <input multiple="multiple" id="selectedImgs" type="file" accept="image/*" onchange="onChangeSelectedImgs()">
                            </form>
                            <button id="btnSelectedImgs" class="btn btn-primary" type="button">파일추가</button>
                        </div>
                    </div>
                    <hr />
                    <div class="row">
                        <div class="col">
                            <h2>선택된 이미지</h2>
                        </div>
                        <div class="col">
                            <button type="button" class="btn btn-primary" onclick="sendImgs()">작업시작</button>
                            <button id="downExcel" type="button" class="btn btn-primary">작업결과 다운</button>
                            <button type="button" class="btn btn-danger" onclick="resetFiles()">목록 초기화</button>


                        </div>
                    </div>

                    <div class="row">
                        <div class="col">
                            <table id="totalTable" class="table">
                                <thead class="thead-dark">
                                    <tr>
                                        <th>불러온파일명</th>
                                        <th>읽어온 번호</th>
                                        <th>파일명 변경</th>
                                        <th>삭제</th>
                                    </tr>
                                </thead>
                                <tbody id="dataTable">
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <hr />
                </div>
            </div>
        </div>
    </div>


    <script>
        var isFinished = false;
        var isProgress = false;
        var hasDownoad = false;
        var remainTask = 0;




        class Queue {
            constructor() {
                this._arr = [];
            }
            enqueue(item) {
                this._arr.push(item);
            }
            dequeue() {
                return this._arr.shift();
            }
            hasData() {
                if (this._arr.length > 0) return true;
                else return false;
            }
        }

        var finishQueue = new Queue();

        var intervalId = null;
        var checkProcess = function() {
            console.info(remainTask);
            if (remainTask == 0) {
                clearInterval(intervalId);
                isProgress = false;
                hasDownoad = true;
                isFinished = true;
                alert("모든 작업이 완료 되었습니다.");
            } else {
                if (finishQueue.hasData()) {
                    remainTask -= finishQueue.dequeue();

                }


            }

        }



        // 이벤트 등록
        $(document).ready(function() {
            // 파일추가 버튼 이벤트
            $('#btnSelectedImgs').click(function(e) {
                if (isProgress) {
                    alert("이미 작업중 입니다. 작업이 모두 끝나면 시도해주세요.");
                    return null;
                }

                $('#selectedImgs').click();
            });

        });



        //엑셀 다운
        $("#downExcel").click(
            function() {
                fnExcelReport("totalTable", "web-cor-작업결과");
            }

        );
        var FILE_LIST = new Array();


        function resetFiles() {
            if (hasDownoad) {
                alert("아직 작업 결과를 한 번도 다운로드하지 않았습니다.");
                return null;
            }
            if (isProgress) {
                alert("작업중에는 목록을 초기화 할수 없습니다.");
                return null;
            }
            FILE_LIST.splice(0, FILE_LIST.length);
            var tbody = document.getElementById("dataTable");
            while (tbody.hasChildNodes()) {
                tbody.removeChild(tbody.firstChild);
            }
            isFinished = false;
            isProgress = false;
        }


        function onChangeSelectedImgs() {
            //function() {
            //console.log("img in changed");
            var files = document.getElementById("selectedImgs").files;
            var fileLen = files.length;
            //console.log(files);
            var dataTable = document.getElementById('dataTable');
            //console.log(dataTable);
            //}
            // 파일을 읽고 dataTable에 정보 추가
            function readAndAdd(file) {



                // `file.name` 형태의 확장자 규칙에 주의하세요
                if (/\.(jpe?g|png|gif)$/i.test(file.name)) {
                    //console.log(FILE_LIST);
                    FILE_LIST.push(file);

                    var reader = new FileReader();

                    reader.addEventListener("load", function() {
                        var tmpRow = document.createElement('tr');
                        var tmpCell1 = document.createElement("td");
                        var tmpCellText1 = document.createTextNode(file.name);
                        tmpCell1.appendChild(tmpCellText1);
                        tmpRow.appendChild(tmpCell1);

                        var tmpCell2 = document.createElement("td");
                        //                        var img = new Image();
                        //                        img.src = this.result;
                        //                        img.className = "thubnail";

                        var tmpCellText2 = document.createTextNode("");
                        tmpCell2.appendChild(tmpCellText2);
                        tmpCell2.appendChild(tmpCellText2);
                        tmpRow.appendChild(tmpCell2);

                        var tmpCell3 = document.createElement("td");
                        var tmpCellText3 = document.createTextNode("");
                        tmpCell3.appendChild(tmpCellText3);
                        tmpRow.appendChild(tmpCell3);


                        var tmpCell4 = document.createElement("td");
                        var buttonDel = document.createElement("button");
                        buttonDel.innerHTML = "삭제";
                        buttonDel.type = "button";
                        buttonDel.className = "btn btn-warning";
                        buttonDel.onclick = function() {
                            var tbody = document.getElementById("dataTable");
                            tbody.removeChild(this.parentElement.parentElement);
                            //행당행의 데이터 삭제
                            FILE_LIST.splice(this.parentElement.rowIndex, 1);
                            //console.info("행삭제, 파일삭제");
                            //console.info(FILE_LIST);
                        };
                        tmpCell4.appendChild(buttonDel);
                        tmpRow.appendChild(tmpCell4);

                        dataTable.appendChild(tmpRow);
                        //console.log(tmpRow);
                    }, false);
                    reader.readAsDataURL(file);

                }
            }


            // files 가 false가 아니라면 
            if (files) {
                [].forEach.call(files, readAndAdd);
                alert("파일 " + files.length + "개가 추가되었습니다.");
            }
            document.getElementById("selectedImgs").value = null;
        }

        function sendImgs() {



            if (isFinished) {
                alert("작업이 모두 끝났습니다. 파일 목록을 초기화한 뒤 다시 시도해주세요.");
                return null;
            }

            if (isProgress) {
                alert("이미 작업중 입니다. 작업이 모두 끝나면 시도해주세요.");
                return null;
            }


            var len = FILE_LIST.length;
            if (len == 0) {
                alert("파일을 추가해 주세요");
                return null;
            }



            isProgress = true;
            remainTask = len;
            for (var i = 0; i < len; i++) {
                //console.info(FILE_LIST[i]);
                sendFile(FILE_LIST[i], i + 1);

            }
            alert("작업을 시작했습니다.");


            intervalId = setInterval(checkProcess, 1000);




        }





        //이미지 업로드 AJAX
        // 이미지 업로드가 session["mem_id"]에 종속됨 없으면 업로드 불가
        function sendFile(file, idx) {



            //console.info("sendFile");
            var formData = new FormData();
            formData.append('mediaFile', file);

            for (var pair of formData.entries()) {
                //console.log(pair[0] + ', ' + pair[1]);
            }

            $.ajax({
                type: 'post',
                url: './uploadimg.action',
                data: formData,
                success: function(status) {
                    if (status != 'error') {
                        // 요청 결과로 td 변경
                        //읽어온 번호 열
                        //console.info(status);
                        var tdReadNum = getTd(idx, 2);

                        //console.info("td is" + tdReadNum);
                        if (tdReadNum.hasChildNodes) {
                            tdReadNum.removeChild(tdReadNum.firstChild);
                        }

                        var tmpCellText1 = document.createTextNode(status);

                        tdReadNum.appendChild(tmpCellText1);

                        // 삭제 버튼 열
                        var tdDel = getTd(idx, 4);

                        //console.info("td is" + tdReadNum);
                        if (tdDel.hasChildNodes) {
                            tdDel.removeChild(tdDel.firstChild);
                        }
                        var tmpCellTex2 = document.createTextNode("작업 완료");
                        tdDel.appendChild(tmpCellTex2);



                        // 파일명 변경 열
                        var tdChangedName = getTd(idx, 3);
                        var fileType = getTd(idx, 1).innerHTML.split(".")[1];
                        var fileName = getTd(idx, 2).innerHTML + "." + fileType;

                        var tmpCellTex3 = document.createTextNode(fileName);
                        tdChangedName.appendChild(tmpCellTex3);

                        finishQueue.enqueue(1);



                    }
                },
                processData: false,
                contentType: false,
                // 아래 error 함수를 이용해 콘솔창으로 디버깅을 한다.
                error: function(jqXHR, textStatus, errorThrown) {
                    //console.log(jqXHR.responseText);
                }
            });

        }

        function getTd(rowIdx, cellIdx) {

            var selectedTd;
            if (rowIdx == 1) {
                if ((selectedTd = document.querySelector("#dataTable > tr:nth-child(1) > td:nth-child(" + cellIdx + ")")) == null) {
                    selectedTd = document.querySelector("#dataTable > tr > td:nth-child(" + cellIdx + ")");
                }
            } else {
                selectedTd = document.querySelector("#dataTable > tr:nth-child(" + rowIdx + ") > td:nth-child(" + cellIdx + ")");
            }
            return selectedTd;
        }




        function fnExcelReport(id, title) {

            if (!isFinished) {
                alert("작업 후에 다운로드해 주세요.");
                return null;
            }
            hasDownoad = false;

            // 엑셀 다운로드
            var tab_text = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
            tab_text = tab_text + '<head><meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8">';
            tab_text = tab_text + '<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>'
            tab_text = tab_text + '<x:Name>Test Sheet</x:Name>';
            tab_text = tab_text + '<x:WorksheetOptions><x:Panes></x:Panes></x:WorksheetOptions></x:ExcelWorksheet>';
            tab_text = tab_text + '</x:ExcelWorksheets></x:ExcelWorkbook></xml></head><body>';
            tab_text = tab_text + "<table border='1px'>";
            var exportTable = $('#' + id).clone();

            //열 삭제
            //console.info(exportTable);

            var thd_tr = exportTable[0].rows;
            //console.info(thd_tr);

            var thd_tr_len = thd_tr.length;
            var thd_td;
            for (var i = 0; i < thd_tr_len; i++) {

                thd_td = thd_tr[i].cells;
                //console.info(thd_td);
                //document.getElementById('msg').innerHTML = thd_td.length;
                if (thd_td.length > 2) {
                    thd_tr[i].deleteCell(thd_td.length - 1);

                }

            }

            exportTable.find('input').each(function(index, elem) {
                $(elem).remove();
            });
            tab_text = tab_text + exportTable.html();
            tab_text = tab_text + '</table></body></html>';
            var data_type = 'data:application/vnd.ms-excel';
            var ua = window.navigator.userAgent;
            var msie = ua.indexOf("MSIE ");
            var fileName = title + '.xls';
            //Explorer 환경에서 다운로드
            if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
                if (window.navigator.msSaveBlob) {
                    var blob = new Blob([tab_text], {
                        type: "application/csv;charset=utf-8;"
                    });
                    navigator.msSaveBlob(blob, fileName);
                }
            } else {
                var blob2 = new Blob([tab_text], {
                    type: "application/csv;charset=utf-8;"
                });
                var filename = fileName;
                var elem = window.document.createElement('a');
                elem.href = window.URL.createObjectURL(blob2);
                elem.download = filename;
                document.body.appendChild(elem);
                elem.click();
                document.body.removeChild(elem);
            }


            // 이미지 다운로드
            var len = FILE_LIST.length;

            for (var i = 0; i < len; i++) {
                //console.info(FILE_LIST[i]);

                var imgName = getTd(i + 1, 3).innerHTML;


                var elem = window.document.createElement('a');
                elem.href = window.URL.createObjectURL(FILE_LIST[i]);
                elem.download = imgName;
                document.body.appendChild(elem);
                elem.click();
                document.body.removeChild(elem);

            }



        }
    </script>


</body>

</html>