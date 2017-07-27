# -*- coding: utf-8 -*-
import xlrd
import json #导入json库
# import collections #有序词典

class ParserExcel(object):
	"""docstring for ParserExcel"""
	_path = None #地址
	_data = None
	_OFF_ROW = 2
	_FORMAT_ROW = 0
	_TITLE_ROW = 1
	def __init__(self, path):
		self._path = path
		self.loadExcel(path)
		
	def loadExcel(self,path):
		self._data = xlrd.open_workbook(path)

	def getSheetByName(self,sheet_name):
		if self._data:
			return self._data.sheet_by_name(sheet_name)

	#根据表名获取对应的obj对象 delete_key是否删除表中作为唯一标志的key clean_None表示是否删除掉空的值
	def getObjBySheetName(self,sheet_name,delete_key = False,clean_None = True):
		sheet = self.getSheetByName(sheet_name)
		if sheet != None:
			title_list = sheet.row_values(self._TITLE_ROW)
			format_list = sheet.row_values(self._FORMAT_ROW)

			col_count = sheet.nrows - self._OFF_ROW # 获取行数,要去掉表头
			# obj_list = collections.OrderedDict() #用有序词典
			obj_list = {}
			for i in range(col_count):
				obj = {}
				for j in range(len(title_list)):
					value = sheet.cell(i + self._OFF_ROW,j).value
					if value or clean_None == False: #有值才加入
						obj[title_list[j]] = self.formatValue(format_list[j],value)

				obj_list[obj[title_list[0]]] = obj
				
				if delete_key == True:
					del obj[title_list[0]]
			return obj_list


	#根据key从对应表中获取对应的obj
	def getObjByKeyOnSheet(self,sheet_name,key,clean_None = True):
		obj_list = self.getObjBySheetName(sheet_name,True,clean_None)
		return obj_list[key]
		
	#根据表明获取对应的json
	def getJsonBySheetName(self,sheet_name,clean_None = True):
		obj_list = self.getObjBySheetName(sheet_name,False,clean_None)
		if obj_list:
			json_data = json.dumps(obj_list,indent = 4,sort_keys=True,ensure_ascii=False)
			return json_data


	def formatValue(self,format,value):
		if value == None:
			return None
		#特殊处理数字带小数点的问题,xlrd库存在的bug
		if type(value) == float:
			if value == int(value):
				value = int(value)

		if format == "int":
			return int(value)
		elif format == "number":
			return float(value)
		elif format == "string":
			return str(value)
		elif format == "json":
			return json.loads(value)
		elif format == "boolean":
			return str(value) == "true"



			

