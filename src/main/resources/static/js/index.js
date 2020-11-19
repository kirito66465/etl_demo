// 整个页面初始化完成之后需要做的一些事情
$(function(){
	$.messager.show({
		title:'系统提示',
		msg:'欢迎使用银行业务平台',
		showType:'show',
		width:'300px',
		height:'250px',
		timeout:1000
	});
	$("#menu a[id]").click(function(e){
		e.preventDefault();
		let tabTitle = $(this).text();
		if( $('#content').tabs('exists',tabTitle) ){
			$('#content').tabs('select',tabTitle)
		}else{
			$('#content').tabs('add',{
				title: tabTitle,
				closable:true,
				content:"<iframe src='"+this.href+"' style='width:100%;height:100%;overflow:hiddens'></iframe>"
			});
		}
	})
});
