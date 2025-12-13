---
title: CSharp中的文件操作
mathjax: true
date: 2024-01-06 23:33:58
tags: C#
description: 在C#中，可以使用System.IO命名空间中的类来进行Windows文件操作。这些类提供了丰富的方法来处理文件和目录，包括创建、复制、删除、移动文件和目录，以及读取和写入文件等功能。
categories: WPF学习笔记
---

在C#中，可以使用System.IO命名空间中的类来进行Windows文件操作。这些类提供了丰富的方法来处理文件和目录，包括创建、复制、删除、移动文件和目录，以及读取和写入文件等功能。

## 常用文件操作方法

### 文件读写

- **读取文件**:
  
  ```csharp
  string content = File.ReadAllText(filePath);
  ```
  
  - 参数：`string path`（要读取的文件的路径）
  - 返回值：`string`（文件的全部文本内容）
  - 说明：读取指定路径的文件全部内容为字符串。
  
- **写入文件**:
  
  ```csharp
  File.WriteAllText(filePath, content);
  ```
  
  - 参数：`string path, string contents`（文件路径和要写入的内容）
  - 返回值：无
  - 说明：将指定的字符串写入文件，如果文件不存在则创建。
  
- **逐行读取**:
  
  ```csharp
  foreach (string line in File.ReadLines(filePath))
  {
      // 处理每一行
  }
  ```
  
  - 参数：`string path`
  - 返回值：`string[]`（文件的所有行）
  - 说明：按行读取文件的全部内容，并以字符串数组的形式返回。
  
- **逐行写入**:
  
  ```csharp
  string[] lines = { "line1", "line2" };
  File.WriteAllLines(filePath, lines);
  ```
  
  - 参数：`string path, IEnumerable<string> contents`（文件路径和包含要写入的所有行的字符串集合）
  
  - 返回值：无
  
  - 说明：将字符串集合中的每个元素按行写入文件。
  
- **ReadAllBytes**

	- 参数：`string path`
	- 返回值：`byte[]`（文件的所有字节）
	- 说明：读取文件的全部内容为字节数组。

-  **WriteAllBytes**

	- 参数：`string path, byte[] bytes`
	- 返回值：无
	- 说明：将字节数组写入文件。

### 文件操作

- **复制文件**:
  ```csharp
  File.Copy(sourceFilePath, destFilePath);
  ```

     - 参数：`string sourceFileName, string destFileName, bool overwrite`（源文件名，目标文件名，是否覆盖）
     - 返回值：无
     - 说明：复制文件到新的位置，可选择是否覆盖现有文件。
  
- **删除文件**:
  ```csharp
  File.Delete(filePath);
  ```

     - 参数：`string path`
     - 返回值：无
     - 说明：删除指定路径的文件。
  
- **移动文件**:
  
  ```csharp
  File.Move(sourceFilePath, destFilePath);
  ```
  
     - 参数：`string sourceFileName, string destFileName`（源文件名，目标文件名）
     - 返回值：无
     - 说明：移动文件到新的位置。
  
- **判断文件是否存在**:
  ```csharp
  bool exists = File.Exists(filePath);
  ```
  
     - 参数：`string path`
     - 返回值：`bool`（文件是否存在）
     - 说明：检查指定路径的文件是否存在。

### 目录操作

- **创建目录**:
  ```csharp
  Directory.CreateDirectory(directoryPath);
  ```

     - 参数：`string path`
     - 返回值：`DirectoryInfo`（表示新创建的目录的对象）
     - 说明：创建目录。
  
- **删除目录**:
  ```csharp
  Directory.Delete(directoryPath, recursive: true);
  ```

     - 参数：`string path, bool recursive`（目录路径，是否递归删除子目录和文件）
     - 返回值：无
     - 说明：删除目录，可选择是否同时删除子目录和文件。
  
- **获取目录下的文件**:
  ```csharp
  string[] files = Directory.GetFiles(directoryPath);
  ```

     - 参数：`string path`
     - 返回值：`string[]`（目录中文件的路径数组）
     - 说明：获取指定目录下的所有文件路径。
  
- **获取目录下的子目录**:
  ```csharp
  string[] subDirectories = Directory.GetDirectories(directoryPath);
  ```
  
     - 参数：`string path`
     - 返回值：`string[]`（目录中子目录的路径数组）
     - 说明：获取指定目录下的所有子目录路径。

### 路径操作

- **合并路径**:
  ```csharp
  string fullPath = Path.Combine(directoryPath, fileName);
  ```

     - 参数：`params string[] paths`
     - 返回值：`string`（组合后的路径）
     - 说明：组合多个字符串为一个路径。
  
- **获取文件名**:
  
  ```csharp
  string fileName = Path.GetFileName(filePath);
  ```
  
     - 参数：`string path`
     - 返回值：`string`（文件名）
     - 说明：从路径字符串中获取文件名。

- **获取目录名**

   ```csharp
   string DirectoryName = Path.GetDirectoryName(filePath);
   ```
   
   - 参数：`string path`
   - 返回值：`string`（目录名）
   - 说明：从路径字符串中获取目录名。

### 使用FileStream

对于需要更细粒度控制的文件操作（如大文件处理或特殊的读写模式），可以使用`FileStream`类。

- **读取文件**:
  ```csharp
  using (FileStream stream = File.OpenRead(filePath))
  {
      // 读取操作
  }
  ```

- **写入文件**:
  ```csharp
  using (FileStream stream = File.OpenWrite(filePath))
  {
      // 写入操作
  }
  ```

## 注意事项

- 在进行文件操作时，需要注意异常处理，如使用try-catch块来捕捉可能出现的错误，例如文件不存在或访问被拒绝等。

- 对于大文件或频繁的文件操作，考虑使用流(Stream)来提高性能。

- 在处理文件路径时，注意操作系统的路径格式。

通过这些方法，可以轻松地在C#中进行各种文件和目录的操作。

在使用这些方法时，最好将它们放在`try-catch`块中，以处理可能发生的异常，如文件不存在、路径错误或访问权限不足等。