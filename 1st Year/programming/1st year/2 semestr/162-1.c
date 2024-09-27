#include <stdio.h>
#include <stdlib.h>
#define NL NULL
// определение макро для указателя NULL, чтобы его использовать в коде

struct node {
    int data;
    struct node *next;
};
// определение структуры node, содержащей данные и указатель на следующий узел списка

struct connecting_node {
    struct node *even_list;
    struct node *odd_list;
};
// определение структуры connecting_node, содержащей указатели на головы двух списков even_list и odd_list 

int main() {
    struct connecting_node con_node = {NL, NL};
    // инициализация списка con_node с указателями на пустые списки
    struct node *even_head = NL, *odd_head = NL;
    struct node *even_tail = NL, *odd_tail = NL;
    // инициализация указателей на голову и хвост каждого списка с помощью макроса NL
    int num;
    int count = 0;
    while (1) {
        scanf("%d", &num);
        if (num == 0) {

            break;
        }
        count++;
        if (count % 2 == 0) {
            // добавление в четный список
            struct node *new_node = (struct node *)malloc(sizeof(struct node));
            // выделение памяти для нового узла
            new_node->data = num;
            new_node->next = NULL;
            // инициализация нового узла
            if (even_head == NULL) {
                even_head = new_node;
                even_tail = new_node;
            } else {
                even_tail->next = new_node;
                even_tail = new_node;
            }
            // добавление нового узла в конец списка
        } else {
            // добавление в нечетный список
            struct node *new_node = (struct node *)malloc(sizeof(struct node));
            new_node->data = num;
            new_node->next = NULL;
            if (odd_head == NULL) {
                odd_head = new_node;
                odd_tail = new_node;
            } else {
                odd_tail->next = new_node;
                odd_tail = new_node;
            }
        }
    }
    con_node.even_list = even_head;
    con_node.odd_list = odd_head;
    // связывание указателей голов списка con_node с последними узлами каждого списка
    printf("Even List: ");
    struct node *current = con_node.even_list;
    while (current != NL) {
        printf("%d ", current->data);
        current = current->next;
    }
    printf("\n");
    // печать элементов четного списка
    printf("Odd List: ");
    current = con_node.odd_list;
    while (current != NL) {
        printf("%d ", current->data);
        current = current->next;
    }
    printf("\n");
    // печать элементов нечетного списка
    while (even_head != NULL) {
        struct node *temp = even_head;
        even_head = even_head->next;
        free(temp);
    }
    even_tail = NULL;
    while (odd_head != NULL) {
        struct node *temp = odd_head;
        odd_head = odd_head->next;
        free(temp);
    }
    odd_tail = NULL;
    // освобождение памяти, занятой списками
    return 0;
}