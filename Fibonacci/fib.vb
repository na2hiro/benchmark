Module Module1

    Sub Main()
        Dim n As Integer = 40
        System.Console.WriteLine("Fib(" & n & ") = " & Fib(n))

    End Sub
    Function Fib(ByVal n As Integer) As Integer
        If n = 0 OrElse n = 1 Then
            Return 1
        Else
            Return Fib(n - 1) + Fib(n - 2)
        End If
    End Function

End Module
